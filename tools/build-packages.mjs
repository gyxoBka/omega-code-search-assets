#!/usr/bin/env node
import crypto from "node:crypto";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import process from "node:process";
import { execFileSync } from "node:child_process";
import { fileURLToPath } from "node:url";

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");

function usage() {
  console.error("Usage: node tools/build-packages.mjs --out <dir> [--domain <packs|harness>] [--assets <domain/id@version,...>] [--update-catalog-source]");
}

function args() {
  const out = new Map();
  const flags = new Set();
  for (let i = 2; i < process.argv.length; i += 1) {
    const key = process.argv[i];
    if (key === "--update-catalog-source") {
      flags.add("update-catalog-source");
      continue;
    }
    if (!key.startsWith("--") || i + 1 >= process.argv.length) {
      usage();
      process.exit(2);
    }
    out.set(key.slice(2), process.argv[i + 1]);
    i += 1;
  }
  if (!out.has("out")) {
    usage();
    process.exit(2);
  }
  return {
    out: path.resolve(out.get("out")),
    domain: out.get("domain") ?? null,
    assets: parseAssetSelection(out.get("assets") ?? null),
    flags,
  };
}

function parseAssetSelection(value) {
  if (value === null) return null;
  if (value.trim() === "") return new Set();
  return new Set(value.split(",").map((item) => item.trim()).filter(Boolean));
}

function assetKey(domain, entry) {
  return `${domain}/${entry.id}@${entry.version}`;
}

function readJson(file) {
  return JSON.parse(fs.readFileSync(file, "utf8"));
}

function writeJson(file, value) {
  fs.writeFileSync(file, `${JSON.stringify(value, null, 2)}\n`);
}

function sha256File(file) {
  const hash = crypto.createHash("sha256");
  hash.update(fs.readFileSync(file));
  return hash.digest("hex");
}

function fileList(root) {
  const out = [];
  function walk(dir) {
    for (const entry of fs.readdirSync(dir, { withFileTypes: true }).sort((a, b) => a.name.localeCompare(b.name))) {
      const full = path.join(dir, entry.name);
      if (entry.isDirectory()) {
        walk(full);
      } else if (entry.isFile()) {
        out.push(path.relative(root, full).replaceAll("\\", "/"));
      }
    }
  }
  walk(root);
  return out;
}

function copyDir(source, destination) {
  fs.mkdirSync(destination, { recursive: true });
  for (const rel of fileList(source)) {
    const target = path.join(destination, rel);
    fs.mkdirSync(path.dirname(target), { recursive: true });
    fs.copyFileSync(path.join(source, rel), target);
  }
}

function normalizeTimestamps(root) {
  const fixed = new Date("2000-01-01T00:00:00Z");
  for (const rel of fileList(root)) fs.utimesSync(path.join(root, rel), fixed, fixed);
}

function zipDirectory(source, archive) {
  fs.rmSync(archive, { force: true });
  const entries = fileList(source);
  if (entries.length === 0) throw new Error(`cannot zip empty directory: ${source}`);
  execFileSync("zip", ["-X", "-q", archive, ...entries], { cwd: source, stdio: "inherit" });
}

function packagePack(entry, outDir) {
  const sourcePack = entry.source_pack.replace(/^assets\//, "");
  const source = path.join(ROOT, sourcePack);
  const temp = fs.mkdtempSync(path.join(os.tmpdir(), "omega-pack-"));
  copyDir(source, temp);
  normalizeTimestamps(temp);
  const archive = path.join(outDir, entry.archive_filename);
  zipDirectory(temp, archive);
  fs.rmSync(temp, { recursive: true, force: true });
  return archive;
}

function packageHarness(entry, outDir) {
  const sourceDefinition = entry.source_definition.replace(/^assets\//, "");
  const source = path.join(ROOT, sourceDefinition);
  const temp = fs.mkdtempSync(path.join(os.tmpdir(), "omega-harness-"));
  fs.copyFileSync(source, path.join(temp, "harness-definition.toml"));
  normalizeTimestamps(temp);
  const archive = path.join(outDir, entry.archive_filename);
  zipDirectory(temp, archive);
  fs.rmSync(temp, { recursive: true, force: true });
  return archive;
}

function buildDomain(domain, catalogFile, packageEntry, outDir, updateSource, selectedAssets, consumedAssets) {
  const catalog = readJson(catalogFile);
  for (const entry of catalog.entries) {
    const key = assetKey(domain, entry);
    if (selectedAssets !== null && !selectedAssets.has(key)) continue;
    consumedAssets.add(key);
    const archive = packageEntry(entry, outDir);
    entry.sha256 = sha256File(archive);
    entry.bytes = fs.statSync(archive).size;
    console.log(`${key} ${entry.sha256} ${entry.bytes}`);
  }
  if (updateSource) writeJson(catalogFile, catalog);
}

const options = args();
fs.mkdirSync(options.out, { recursive: true });
const requestedDomain = options.domain ?? null;
const consumedAssets = new Set();
if (requestedDomain === null || requestedDomain === "packs") {
  buildDomain(
    "packs",
    path.join(ROOT, "packs", "catalog-source.json"),
    packagePack,
    options.out,
    options.flags.has("update-catalog-source"),
    options.assets,
    consumedAssets,
  );
}
if (requestedDomain === null || requestedDomain === "harness") {
  buildDomain(
    "harness",
    path.join(ROOT, "harness", "catalog-source.json"),
    packageHarness,
    options.out,
    options.flags.has("update-catalog-source"),
    options.assets,
    consumedAssets,
  );
}
if (requestedDomain !== null && !["packs", "harness"].includes(requestedDomain)) {
  throw new Error(`unsupported domain: ${requestedDomain}`);
}
if (options.assets !== null) {
  const missing = [...options.assets].filter((asset) => !consumedAssets.has(asset));
  if (missing.length > 0) throw new Error(`selected assets were not found: ${missing.join(", ")}`);
}
