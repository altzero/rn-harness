#!/usr/bin/env node
// feature-list-check.js — validates the features/ directory.
//
// Replaces the old single-file feature_list.json. Now each feature is
// its own file at features/<feature-id>.json. Two branches that add
// different features no longer collide on a shared array. Same
// validation rules as before, applied per-file plus across the set:
//
//   - id format             <category>-<slug>, lowercase, no -NNN suffix
//   - filename matches id   features/foo.json must have id "foo"
//   - required fields       id, title, description, verification[],
//                           status, passes
//   - status                in {todo, in_progress, blocked, done}
//   - done                  must have passes: true and commitSha
//   - WIP                   ≤ WIP_LIMIT (= 1) in_progress features
//
// Run by init.sh, npm run verify, and the CI static job.

const fs = require('fs');
const path = require('path');

const FEATURES_DIR = path.resolve(__dirname, '..', 'features');
const WIP_LIMIT = 1;
const VALID_STATUSES = new Set(['todo', 'in_progress', 'blocked', 'done']);
const REQUIRED_FIELDS = ['id', 'title', 'description', 'verification', 'status', 'passes'];
// Canonical id: <category>-<slug>, where each segment starts with a
// letter and may contain digits. At least one dash is required so a
// bare category like "ui" is not a valid feature id.
const ID_PATTERN = /^[a-z][a-z0-9]*(-[a-z][a-z0-9]*)+$/;

function die(msg) {
  console.error(`features: ${msg}`);
  process.exit(1);
}

if (!fs.existsSync(FEATURES_DIR)) {
  die(`features/ directory missing at ${FEATURES_DIR}`);
}

const files = fs
  .readdirSync(FEATURES_DIR)
  .filter(f => f.endsWith('.json'))
  .sort();

if (files.length === 0) {
  die(`features/ directory is empty`);
}

const seenIds = new Set();
let inProgressCount = 0;
const counts = { todo: 0, in_progress: 0, blocked: 0, done: 0 };

for (const file of files) {
  const fullPath = path.join(FEATURES_DIR, file);
  const where = `features/${file}`;

  let f;
  try {
    f = JSON.parse(fs.readFileSync(fullPath, 'utf8'));
  } catch (e) {
    die(`${where}: invalid JSON — ${e.message}`);
  }

  for (const k of REQUIRED_FIELDS) {
    if (!(k in f)) die(`${where}: missing required field "${k}"`);
  }

  if (!ID_PATTERN.test(f.id)) {
    die(`${where}: id "${f.id}" doesn't match <category>-<slug> (see docs/HARNESS.md → Naming standard)`);
  }

  const expectedId = file.replace(/\.json$/, '');
  if (f.id !== expectedId) {
    die(`${where}: filename id "${expectedId}" does not match field id "${f.id}"`);
  }

  if (seenIds.has(f.id)) die(`${where}: duplicate id "${f.id}"`);
  seenIds.add(f.id);

  if (!VALID_STATUSES.has(f.status)) {
    die(`${where}: status "${f.status}" not in ${[...VALID_STATUSES].join(', ')}`);
  }
  if (!Array.isArray(f.verification) || f.verification.length === 0) {
    die(`${where}: verification must be a non-empty array of strings`);
  }
  if (typeof f.passes !== 'boolean') {
    die(`${where}: passes must be boolean`);
  }
  if (f.status === 'done' && f.passes !== true) {
    die(`${where}: status=done requires passes:true`);
  }
  if (f.status === 'done' && !f.commitSha) {
    die(`${where}: status=done requires a non-empty commitSha`);
  }

  if (f.status === 'in_progress') inProgressCount++;
  counts[f.status]++;
}

if (inProgressCount > WIP_LIMIT) {
  die(`${inProgressCount} features are in_progress; WIP_LIMIT is ${WIP_LIMIT}. See docs/HARNESS.md.`);
}

console.log(
  `features: ok (${files.length} features — ` +
    Object.entries(counts).map(([k, v]) => `${k}:${v}`).join(' ') +
    `)`
);
