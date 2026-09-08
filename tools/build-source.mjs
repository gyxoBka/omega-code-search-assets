#!/usr/bin/env node
import crypto from "node:crypto";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import process from "node:process";
import { fileURLToPath } from "node:url";

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");

function usage() {
  console.error("Usage: node tools/build-source.mjs [--out dist] [--assets <name@version,...>] [--no-clean]");
}

function parseArgs() {
  const out = { out: path.join(ROOT, "dist"), assets: null, clean: true };
  for (let i = 2; i < process.argv.length; i += 1) {
    const arg = process.argv[i];
    if (arg === "--no-clean") {
      out.clean = false;
    } else if (arg === "--out" && process.argv[i + 1]) {
      out.out = path.resolve(process.argv[++i]);
    } else if (arg === "--assets" && process.argv[i + 1]) {
      out.assets = new Set(process.argv[++i].split(",").map((x) => x.trim()).filter(Boolean));
    } else {
      usage();
      process.exit(2);
    }
  }
  return out;
}

function unixPath(value) {
  return value.replaceAll("\\", "/");
}

function fileList(root) {
  const out = [];
  function walk(dir) {
    for (const entry of fs.readdirSync(dir, { withFileTypes: true }).sort((a, b) => a.name.localeCompare(b.name))) {
      const full = path.join(dir, entry.name);
      if (entry.isDirectory()) walk(full);
      else if (entry.isFile()) out.push(unixPath(path.relative(root, full)));
    }
  }
  walk(root);
  return out;
}

function sha256File(file) {
  const hash = crypto.createHash("sha256");
  hash.update(fs.readFileSync(file));
  return hash.digest("hex");
}

function normalizeTimestamps(root) {
  const fixed = new Date("2000-01-01T00:00:00Z");
  for (const rel of fileList(root)) fs.utimesSync(path.join(root, rel), fixed, fixed);
}

function copyDir(source, destination) {
  fs.mkdirSync(destination, { recursive: true });
  for (const rel of fileList(source)) {
    const target = path.join(destination, rel);
    fs.mkdirSync(path.dirname(target), { recursive: true });
    fs.copyFileSync(path.join(source, rel), target);
  }
}

function parseTomlScalars(text) {
  const out = new Map();
  for (const raw of text.split(/\r?\n/)) {
    const line = raw.trim();
    if (!line || line.startsWith("#")) continue;
    if (line.startsWith("[")) break;
    const m = line.match(/^([A-Za-z0-9_.-]+)\s*=\s*(.+)$/);
    if (!m) continue;
    let value = m[2].trim();
    if (value.startsWith('"') && value.endsWith('"')) value = value.slice(1, -1);
    out.set(m[1], value);
  }
  return out;
}

const CRC32_TABLE = new Uint32Array(256);
for (let i = 0; i < 256; i += 1) {
  let c = i;
  for (let bit = 0; bit < 8; bit += 1) c = c & 1 ? 0xedb88320 ^ (c >>> 1) : c >>> 1;
  CRC32_TABLE[i] = c >>> 0;
}

function crc32(bytes) {
  let c = 0xffffffff;
  for (const byte of bytes) c = CRC32_TABLE[(c ^ byte) & 0xff] ^ (c >>> 8);
  return (c ^ 0xffffffff) >>> 0;
}

function u16(value) {
  const out = Buffer.alloc(2);
  out.writeUInt16LE(value);
  return out;
}

function u32(value) {
  const out = Buffer.alloc(4);
  out.writeUInt32LE(value >>> 0);
  return out;
}

function zipDirectory(source, archive) {
  fs.rmSync(archive, { force: true });
  const entries = fileList(source);
  if (entries.length === 0) throw new Error(`cannot zip empty directory: ${source}`);
  const localParts = [];
  const centralParts = [];
  let offset = 0;
  for (const entry of entries) {
    const name = Buffer.from(entry, "utf8");
    const data = fs.readFileSync(path.join(source, entry));
    const checksum = crc32(data);
    const local = Buffer.concat([
      u32(0x04034b50), u16(20), u16(0x0800), u16(0), u16(0), u16(0x2821),
      u32(checksum), u32(data.length), u32(data.length), u16(name.length), u16(0), name, data,
    ]);
    const central = Buffer.concat([
      u32(0x02014b50), u16(20), u16(20), u16(0x0800), u16(0), u16(0), u16(0x2821),
      u32(checksum), u32(data.length), u32(data.length), u16(name.length), u16(0), u16(0), u16(0), u16(0), u32(0), u32(offset), name,
    ]);
    localParts.push(local);
    centralParts.push(central);
    offset += local.length;
  }
  const central = Buffer.concat(centralParts);
  const end = Buffer.concat([u32(0x06054b50), u16(0), u16(0), u16(entries.length), u16(entries.length), u32(central.length), u32(offset), u16(0)]);
  fs.mkdirSync(path.dirname(archive), { recursive: true });
  fs.writeFileSync(archive, Buffer.concat([...localParts, central, end]));
}

function discoverAssets() {
  const domains = [
    { dir: "grammars", className: "GRAMMAR_BUNDLE", versionField: "bundle_version", idField: "parser_id", manifest: "manifest.toml" },
    { dir: "packs", className: "LANGUAGE_PACK", versionField: "version", idField: "name", manifest: "manifest.toml" },
    { dir: "frameworks", className: "FRAMEWORK_PACK", versionField: "version", idField: "name", manifest: "manifest.toml" },
  ];
  const assets = [];
  for (const domain of domains) {
    const abs = path.join(ROOT, domain.dir);
    if (!fs.existsSync(abs)) continue;
    for (const entry of fs.readdirSync(abs, { withFileTypes: true }).filter((x) => x.isDirectory() && !fs.existsSync(path.join(abs, x.name, '.omega-staged')))) {
      const assetPath = `${domain.dir}/${entry.name}`;
      const manifestPath = path.join(abs, entry.name, domain.manifest);
      if (!fs.existsSync(manifestPath)) throw new Error(`${assetPath} missing ${domain.manifest}`);
      const manifest = parseTomlScalars(fs.readFileSync(manifestPath, "utf8"));
      const fallback = entry.name.includes("@") ? entry.name.split("@")[0] : entry.name;
      const id = manifest.get(domain.idField) || manifest.get("grammar_id") || fallback;
      const version = manifest.get(domain.versionField) || (entry.name.includes("@") ? entry.name.split("@").slice(1).join("@") : "0.0.0");
      assets.push({ class: domain.className, id, version, path: assetPath, domain: domain.dir });
    }
  }
  return assets.sort((a, b) => `${a.class}\0${a.id}\0${a.version}`.localeCompare(`${b.class}\0${b.id}\0${b.version}`));
}

function selected(asset, selection) {
  if (!selection) return true;
  const keys = [`${asset.id}@${asset.version}`, `${asset.class}/${asset.id}@${asset.version}`, asset.path, `${asset.domain}/${asset.id}@${asset.version}`];
  return keys.some((key) => selection.has(key));
}

function packageAsset(asset, packagesRoot) {
  const source = path.join(ROOT, asset.path);
  const archiveName = `${path.basename(asset.path)}.zip`.replaceAll(/[\\/:*?"<>|]/g, "_");
  const archive = path.join(packagesRoot, asset.domain, archiveName);
  const temp = fs.mkdtempSync(path.join(os.tmpdir(), "omega-asset-"));
  copyDir(source, temp);
  normalizeTimestamps(temp);
  zipDirectory(temp, archive);
  fs.rmSync(temp, { recursive: true, force: true });
  return {
    class: asset.class,
    id: asset.id,
    version: asset.version,
    source_path: asset.path,
    archive: unixPath(path.relative(ROOT, archive)),
    sha256: sha256File(archive),
    bytes: fs.statSync(archive).size,
  };
}

function archiveRelativePath(asset) {
  const archiveName = `${path.basename(asset.path)}.zip`.replaceAll(/[\/:*?"<>|]/g, "_");
  return unixPath(path.join("packages", asset.domain, archiveName));
}

function assertUniqueArchives(assets) {
  const seen = new Map();
  for (const asset of assets) {
    const archive = archiveRelativePath(asset);
    const previous = seen.get(archive);
    if (previous) {
      throw new Error(`duplicate archive target ${archive}: ${previous.id}@${previous.version} and ${asset.id}@${asset.version}`);
    }
    seen.set(archive, asset);
  }
}

const options = parseArgs();
if (options.clean) fs.rmSync(options.out, { recursive: true, force: true });
const discovered = discoverAssets();
const assets = discovered.filter((asset) => selected(asset, options.assets));
assertUniqueArchives(assets);
if (options.assets && assets.length !== options.assets.size) {
  const matched = new Set(assets.flatMap((asset) => [`${asset.id}@${asset.version}`, `${asset.class}/${asset.id}@${asset.version}`, asset.path, `${asset.domain}/${asset.id}@${asset.version}`]));
  const missing = [...options.assets].filter((key) => !matched.has(key));
  throw new Error(`unknown selected assets: ${missing.join(", ")}`);
}

const packagesRoot = path.join(options.out, "packages");
const entries = assets.map((asset) => packageAsset(asset, packagesRoot));
const catalogSource = {
  schema_version: 1,
  generated_at: new Date().toISOString().replace(/\.\d{3}Z$/, "Z"),
  entries,
};
fs.mkdirSync(options.out, { recursive: true });
const catalogJson = `${JSON.stringify(catalogSource, null, 2)}\n`;
fs.writeFileSync(path.join(options.out, "catalog.json"), catalogJson);

console.log(JSON.stringify({
  result: "pass",
  discovered_assets: discovered.length,
  built_assets: entries.length,
  out: unixPath(path.relative(ROOT, options.out)),
  catalog: unixPath(path.relative(ROOT, path.join(options.out, "catalog.json"))),
}, null, 2));
