#!/usr/bin/env node
// feature-list-check.js — schema validator for feature_list.json.
// Run by init.sh, verify.sh, and check-clean-state.sh. Exits non-zero on
// any violation with a single-line reason.

const fs = require('fs');
const path = require('path');

const FILE = path.resolve(__dirname, '..', 'feature_list.json');
const VALID_STATUSES = new Set(['todo', 'in_progress', 'blocked', 'done']);
const REQUIRED_FIELDS = ['id', 'title', 'description', 'verification', 'status', 'passes'];

function die(msg) {
  console.error(`feature_list.json: ${msg}`);
  process.exit(1);
}

let raw;
try {
  raw = fs.readFileSync(FILE, 'utf8');
} catch (e) {
  die(`cannot read ${FILE}: ${e.message}`);
}

let data;
try {
  data = JSON.parse(raw);
} catch (e) {
  die(`invalid JSON: ${e.message}`);
}

if (!Array.isArray(data.features)) {
  die('top-level `features` must be an array');
}

const seenIds = new Set();
let inProgressCount = 0;

for (const [i, f] of data.features.entries()) {
  const where = `features[${i}]${f.id ? ` (id=${f.id})` : ''}`;
  for (const k of REQUIRED_FIELDS) {
    if (!(k in f)) die(`${where} missing required field "${k}"`);
  }
  if (!/^[a-z0-9-]+$/.test(f.id)) {
    die(`${where} id must be lowercase kebab-case (got "${f.id}")`);
  }
  if (seenIds.has(f.id)) die(`${where} duplicate id "${f.id}"`);
  seenIds.add(f.id);

  if (!VALID_STATUSES.has(f.status)) {
    die(`${where} status "${f.status}" not in ${[...VALID_STATUSES].join(', ')}`);
  }
  if (!Array.isArray(f.verification) || f.verification.length === 0) {
    die(`${where} verification must be a non-empty array of strings`);
  }
  if (typeof f.passes !== 'boolean') {
    die(`${where} passes must be boolean`);
  }
  if (f.status === 'done' && f.passes !== true) {
    die(`${where} status=done but passes=false — set passes:true and fill commitSha`);
  }
  if (f.status === 'done' && !f.commitSha) {
    die(`${where} status=done but commitSha is empty`);
  }
  if (f.status === 'in_progress') inProgressCount++;
}

const wipLimit = data.wipLimit ?? 1;
if (inProgressCount > wipLimit) {
  die(`${inProgressCount} features are in_progress; wipLimit is ${wipLimit}. WIP=1 (see docs/HARNESS.md).`);
}

const counts = { todo: 0, in_progress: 0, blocked: 0, done: 0 };
for (const f of data.features) counts[f.status]++;
console.log(
  `feature_list.json: ok (${data.features.length} features — ` +
    Object.entries(counts).map(([k, v]) => `${k}:${v}`).join(' ') +
    `)`
);
