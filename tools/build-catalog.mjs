#!/usr/bin/env node
import crypto from "node:crypto";
import fs from "node:fs";
import path from "node:path";
import process from "node:process";
import { fileURLToPath } from "node:url";

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");

function usage() {
  console.error(`Usage:
node tools/build-catalog.mjs --domain <domain> --registry-digests <file> --catalog-version <version> --out <path>

Domains:
  packs
  harness

Environment for signed output:
  OMEGA_ASSET_CATALOG_PRIVATE_KEY_PEM  Ed25519 private key in PEM form
  OMEGA_ASSET_CATALOG_KEY_ID           public key id embedded in Omega builds

Optional:
  --previous-catalog <file>                 current published catalog to reuse unchanged entries
  OMEGA_ASSET_CATALOG_CHANNEL          default: stable
  OMEGA_ASSET_MINIMUM_RUNTIME          default: >=0.1.0
`);
}

function args() {
  const out = new Map();
  for (let i = 2; i < process.argv.length; i += 1) {
    const key = process.argv[i];
    if (!key.startsWith("--") || i + 1 >= process.argv.length) {
      usage();
      process.exit(2);
    }
    out.set(key.slice(2), process.argv[i + 1]);
    i += 1;
  }
  for (const required of ["domain", "registry-digests", "catalog-version", "out"]) {
    if (!out.has(required)) {
      usage();
      process.exit(2);
    }
  }
  return out;
}

function readJson(file) {
  return JSON.parse(fs.readFileSync(file, "utf8"));
}

function sha256File(file) {
  const hash = crypto.createHash("sha256");
  hash.update(fs.readFileSync(file));
  return hash.digest("hex");
}

function unixPath(value) {
  return value.replaceAll("\\", "/");
}

function jcs(value) {
  if (value === null) return "null";
  if (Array.isArray(value)) return `[${value.map(jcs).join(",")}]`;
  switch (typeof value) {
    case "boolean":
      return value ? "true" : "false";
    case "number":
      if (!Number.isFinite(value)) throw new Error("non-finite number in catalog payload");
      return JSON.stringify(value);
    case "string":
      return JSON.stringify(value);
    case "object": {
      const keys = Object.keys(value).sort();
      return `{${keys.map((key) => `${JSON.stringify(key)}:${jcs(value[key])}`).join(",")}}`;
    }
    default:
      throw new Error(`unsupported JSON value type: ${typeof value}`);
  }
}

function entryKey(entry) {
  return `${entry.class}/${entry.id}@${entry.version}`;
}

function publicCatalogEntry(domain, source, registryDigests, previousEntries) {
  const key = `${domain}/${source.id}@${source.version}`;
  const published = registryDigests[key];
  if (!published) {
    const previous = previousEntries.get(`${source.class}/${source.id}@${source.version}`);
    if (previous) return { entry: previous };
    throw new Error(`missing OCI digest mapping for ${key}; no previous catalog entry is available`);
  }
  const entry = {
    class: source.class,
    id: source.id,
    version: source.version,
    sha256: source.sha256,
    bytes: source.bytes,
    license: source.license,
    origin_url: `oci://${published.immutable_reference}`,
    archive: source.archive,
    minimum_runtime: source.minimum_runtime ?? null,
  };
  for (const key of [
    "pack_compatibility",
    "grammar_compatibility",
    "harness_compatibility",
    "model_descriptor_compatibility",
    "offline_snapshot_compatibility",
    "grammar_detection",
  ]) {
    if (source[key] !== undefined) entry[key] = source[key];
  }
  return { entry };
}

function previousEntriesFromCatalog(file) {
  const entries = new Map();
  if (file === null) return entries;
  const catalog = readJson(file);
  const catalogEntries = catalog.signed?.entries;
  if (!Array.isArray(catalogEntries)) {
    throw new Error(`${file} is not a signed Omega catalog`);
  }
  for (const entry of catalogEntries) entries.set(entryKey(entry), entry);
  return entries;
}

function catalogSourceForDomain(domain) {
  switch (domain) {
    case "packs":
      return {
        file: path.join(ROOT, "packs", "catalog-source.json"),
      };
    case "harness":
      return {
        file: path.join(ROOT, "harness", "catalog-source.json"),
      };
    default:
      throw new Error(`unsupported catalog domain: ${domain}`);
  }
}

function expectedClassesForDomain(domain) {
  switch (domain) {
    case "packs":
      return new Set(["LANGUAGE_PACK", "FRAMEWORK_PACK"]);
    case "harness":
      return new Set(["HARNESS_DEFINITION"]);
    default:
      throw new Error(`unsupported catalog domain: ${domain}`);
  }
}

function loadCatalogSource(domain, registryDigests, previousEntries) {
  const source = catalogSourceForDomain(domain);
  const expectedClasses = expectedClassesForDomain(domain);
  const items = [];
  if (!fs.existsSync(source.file)) throw new Error(`${source.file} does not exist`);
  const catalog = readJson(source.file);
  if (catalog.schema_version !== 1 || !Array.isArray(catalog.entries)) {
    throw new Error(`${source.file} is not a supported catalog source`);
  }
  for (const raw of catalog.entries) {
    if (!expectedClasses.has(raw.class)) {
      throw new Error(`${source.file} contains ${raw.class}, which is invalid for ${domain}`);
    }
    items.push(publicCatalogEntry(domain, raw, registryDigests, previousEntries));
  }
  items.sort((a, b) =>
    `${a.entry.class}\0${a.entry.id}\0${a.entry.version}`.localeCompare(
      `${b.entry.class}\0${b.entry.id}\0${b.entry.version}`,
    ),
  );
  return items;
}

function signPayload(payload) {
  const privateKeyPem = process.env.OMEGA_ASSET_CATALOG_PRIVATE_KEY_PEM;
  const keyId = process.env.OMEGA_ASSET_CATALOG_KEY_ID;
  if (!privateKeyPem && !keyId) return [];
  if (!privateKeyPem || !keyId) {
    throw new Error("both OMEGA_ASSET_CATALOG_PRIVATE_KEY_PEM and OMEGA_ASSET_CATALOG_KEY_ID are required for signing");
  }
  const signature = crypto.sign(null, Buffer.from(jcs(payload), "utf8"), privateKeyPem);
  return [
    {
      key_id: keyId,
      algorithm: "ed25519",
      signature_b64: signature.toString("base64"),
    },
  ];
}

const options = args();
const domain = options.get("domain");
const outFile = path.resolve(options.get("out"));
const registryDigests = readJson(path.resolve(options.get("registry-digests")));
const previousCatalog = options.has("previous-catalog") ? path.resolve(options.get("previous-catalog")) : null;
const previousEntries = previousEntriesFromCatalog(previousCatalog);
const items = loadCatalogSource(domain, registryDigests, previousEntries);
if (items.length === 0) throw new Error("no catalog entries found");

const payload = {
  catalog_schema: 1,
  catalog_version: options.get("catalog-version"),
  channel: process.env.OMEGA_ASSET_CATALOG_CHANNEL ?? domain,
  published_at: new Date().toISOString().replace(/\.\d{3}Z$/, "Z"),
  minimum_runtime: process.env.OMEGA_ASSET_MINIMUM_RUNTIME ?? ">=0.1.0",
  entries: items.map((item) => item.entry),
};

const catalog = {
  signed: payload,
  signatures: signPayload(payload),
};

fs.mkdirSync(path.dirname(outFile), { recursive: true });
fs.writeFileSync(outFile, `${JSON.stringify(catalog, null, 2)}\n`);
console.log(`wrote ${unixPath(path.relative(process.cwd(), outFile))}`);
console.log(`entries=${items.length} signed=${catalog.signatures.length > 0}`);
