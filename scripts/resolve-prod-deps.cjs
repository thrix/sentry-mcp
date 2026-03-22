#!/usr/bin/env node

/**
 * Generate a standalone package.json with resolved production dependency
 * versions. This is needed because the workspace uses pnpm's catalog:
 * protocol for version resolution, which npm cannot understand.
 *
 * Used during container builds to produce a portable package.json that
 * npm can install from in the runtime stage.
 *
 * Usage: node scripts/resolve-prod-deps.cjs <package-dir> <output-path>
 */

const { execSync } = require("node:child_process");
const fs = require("node:fs");
const path = require("node:path");

const pkgDir = process.argv[2] || "packages/mcp-server";
const outputPath = process.argv[3] || "/tmp/package.json";

const pkg = require(path.resolve(pkgDir, "package.json"));
const out = execSync("pnpm ls --prod --json", {
  cwd: pkgDir,
  encoding: "utf8",
});

const deps = JSON.parse(out)[0]?.dependencies || {};
const resolved = {};
for (const [name, info] of Object.entries(deps)) {
  resolved[name] = info.version;
}

const runtime = {
  name: pkg.name,
  version: pkg.version,
  type: pkg.type,
  dependencies: resolved,
};

fs.writeFileSync(outputPath, `${JSON.stringify(runtime, null, 2)}\n`);
console.log(`Resolved ${Object.keys(resolved).length} production dependencies`);
