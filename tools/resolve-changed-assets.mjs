#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import process from "node:process";
import { execFileSync } from "node:child_process";
import { fileURLToPath } from "node:url";

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");

function usage() {
  console.error("Usage: node tools/resolve-changed-assets.mjs --base <rev> --head <rev> --out <file> [--mode <changed|all|packs|harness>]");
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
  for (const required of ["base", "head", "out"]) {
    if (!out.has(required)) {
      usage();
      process.exit(2);
    }
  }
  return {
    base: out.get("base"),
    head: out.get("head"),
    out: path.resolve(out.get("out")),
    mode: out.get("mode") ?? "changed",
  };
}

function readJson(file) {
  return JSON.parse(fs.readFileSync(path.join(ROOT, file), "utf8"));
}

function readJsonAt(rev, file) {
  try {
    const output = execFileSync("git", ["show", `${rev}:${file}`], {
      cwd: ROOT,
      encoding: "utf8",
      stdio: ["ignore", "pipe", "ignore"],
    });
    return JSON.parse(output);
  } catch {
    return null;
  }
}

function assetKey(domain, entry) {
  return `${domain}/${entry.id}@${entry.version}`;
}

function allAssets(domain) {
  const file = domain === "packs" ? "packs/catalog-source.json" : "harness/catalog-source.json";
  return readJson(file).entries.map((entry) => assetKey(domain, entry));
}

function packBySourceDir() {
  const out = new Map();
  for (const entry of readJson("packs/catalog-source.json").entries) {
    out.set(entry.source_pack.replace(/^assets\//, ""), assetKey("packs", entry));
  }
  return out;
}

function harnessBySourceDefinition() {
  const out = new Map();
  for (const entry of readJson("harness/catalog-source.json").entries) {
    out.set(
      entry.source_definition.replace(/^assets\//, ""),
      assetKey("harness", entry),
    );
  }
  return out;
}

function changedCatalogSourceAssets(domain, base) {
  const file = domain === "packs" ? "packs/catalog-source.json" : "harness/catalog-source.json";
  const previous = readJsonAt(base, file);
  const current = readJson(file);
  if (previous === null) return allAssets(domain);

  const previousEntries = new Map(previous.entries.map((entry) => [assetKey(domain, entry), JSON.stringify(entry)]));
  const selected = [];
  for (const entry of current.entries) {
    const key = assetKey(domain, entry);
    if (previousEntries.get(key) !== JSON.stringify(entry)) selected.push(key);
  }
  return selected;
}

function changedFiles(base, head) {
  const output = execFileSync("git", ["diff", "--name-only", base, head], {
    cwd: ROOT,
    encoding: "utf8",
  });
  return output.split(/\r?\n/).map((line) => line.trim()).filter(Boolean);
}

function add(set, values) {
  for (const value of values) set.add(value);
}

const options = args();
const selected = new Set();
const catalogDomains = new Set();
if (options.mode === "all") {
  add(selected, allAssets("packs"));
  add(selected, allAssets("harness"));
  catalogDomains.add("packs");
  catalogDomains.add("harness");
} else if (options.mode === "packs" || options.mode === "harness") {
  add(selected, allAssets(options.mode));
  catalogDomains.add(options.mode);
} else if (options.mode !== "changed") {
  throw new Error(`unsupported mode: ${options.mode}`);
} else {
  const packs = packBySourceDir();
  const harness = harnessBySourceDefinition();
  for (const file of changedFiles(options.base, options.head)) {
    if (file.startsWith("tools/") || file.startsWith(".github/workflows/")) {
      continue;
    }
    if (file === "packs/catalog-source.json") {
      catalogDomains.add("packs");
      add(selected, changedCatalogSourceAssets("packs", options.base));
      continue;
    }
    if (file === "harness/catalog-source.json") {
      catalogDomains.add("harness");
      add(selected, changedCatalogSourceAssets("harness", options.base));
      continue;
    }
    for (const [dir, key] of packs) {
      if (file === dir || file.startsWith(`${dir}/`)) {
        selected.add(key);
        catalogDomains.add("packs");
      }
    }
    for (const [definition, key] of harness) {
      if (file === definition) {
        selected.add(key);
        catalogDomains.add("harness");
      }
    }
  }
}

const assets = [...selected].sort();
const byDomain = {};
for (const asset of assets) {
  const domain = asset.split("/", 1)[0];
  (byDomain[domain] ??= []).push(asset);
  catalogDomains.add(domain);
}
const result = { assets, domains: [...catalogDomains].sort(), by_domain: byDomain };
fs.mkdirSync(path.dirname(options.out), { recursive: true });
fs.writeFileSync(options.out, `${JSON.stringify(result, null, 2)}\n`);
console.log(JSON.stringify(result));
