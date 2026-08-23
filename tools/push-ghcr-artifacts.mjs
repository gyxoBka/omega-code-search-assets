#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import process from "node:process";
import { execFileSync } from "node:child_process";
import { fileURLToPath } from "node:url";

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");

function usage() {
  console.error("Usage: node tools/push-ghcr-artifacts.mjs --packages <dir> --out <file> [--domain <packs|harness>] [--assets <domain/id@version,...>]");
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
  for (const required of ["packages", "out"]) {
    if (!out.has(required)) {
      usage();
      process.exit(2);
    }
  }
  return {
    packages: path.resolve(out.get("packages")),
    out: path.resolve(out.get("out")),
    domain: out.get("domain") ?? null,
    assets: parseAssetSelection(out.get("assets") ?? null),
  };
}

function parseAssetSelection(value) {
  if (value === null) return null;
  if (value.trim() === "") return new Set();
  return new Set(value.split(",").map((item) => item.trim()).filter(Boolean));
}

function assetKey(entry) {
  return `${entry.domain}/${entry.id}@${entry.version}`;
}

function readJson(file) {
  return JSON.parse(fs.readFileSync(file, "utf8"));
}

function push(reference, packageRoot, archive) {
  const file = path.join(packageRoot, archive);
  const relative = path.relative(packageRoot, file).replaceAll("\\", "/");
  if (relative.startsWith("../") || path.isAbsolute(relative)) {
    throw new Error(`archive escapes package root: ${archive}`);
  }
  if (!fs.statSync(file).isFile()) throw new Error(`archive is not a file: ${file}`);
  const output = execFileSync(
    "oras",
    [
      "push",
      reference,
      `${relative}:application/vnd.omega.asset.archive.zip`,
      "--artifact-type",
      "application/vnd.omega.asset.v1",
      "--annotation",
      "org.opencontainers.image.source=https://github.com/gyxoBka/omega-code-search-assets",
    ],
    { cwd: packageRoot, encoding: "utf8" },
  );
  process.stdout.write(output);
  const match = output.match(/Digest:\s*(sha256:[a-f0-9]{64})/i);
  if (!match) throw new Error(`oras output did not contain digest for ${reference}`);
  return match[1];
}

function entries(domainFilter, selectedAssets) {
  if (domainFilter !== null && !["packs", "harness"].includes(domainFilter)) {
    throw new Error(`unsupported domain: ${domainFilter}`);
  }
  return [
    ["packs", path.join(ROOT, "packs", "catalog-source.json")],
    ["harness", path.join(ROOT, "harness", "catalog-source.json")],
  ].filter(([domain]) => domainFilter === null || domain === domainFilter)
    .flatMap(([domain, file]) => readJson(file).entries.map((entry) => ({
      domain,
      id: entry.id,
      version: entry.version,
      archive: entry.archive_filename,
    })))
    .filter((entry) => selectedAssets === null || selectedAssets.has(assetKey(entry)));
}

const options = args();
const mapping = {};
const selectedEntries = entries(options.domain, options.assets);
if (options.assets !== null) {
  const found = new Set(selectedEntries.map(assetKey));
  const missing = [...options.assets].filter((asset) => !found.has(asset));
  if (missing.length > 0) throw new Error(`selected assets were not found: ${missing.join(", ")}`);
}
for (const entry of selectedEntries) {
  const reference = `ghcr.io/gyxobka/omega-code-search-assets/${entry.domain}/${entry.id}:${entry.version}`;
  const digest = push(reference, options.packages, entry.archive);
  mapping[assetKey(entry)] = {
    reference,
    digest,
    immutable_reference: `${reference.split(":")[0]}@${digest}`,
  };
}
fs.mkdirSync(path.dirname(options.out), { recursive: true });
fs.writeFileSync(options.out, `${JSON.stringify(mapping, null, 2)}\n`);
