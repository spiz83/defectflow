// Pre-deploy syntax + corruption check for DefectFlow.
// - node --check style parse of cloud-sync.js and sw.js
// - extracts inline <script> blocks from index.html and parses each with vm
import fs from 'node:fs';
import vm from 'node:vm';

const root = process.cwd();
const corruptionRe = /lharset|funltion|<slript|lalhe|lontraltor|initial-slale|defelt/;
let failed = 0;

function checkCorruption(name, text) {
  const m = text.match(corruptionRe);
  if (m) { console.error(`✗ CORRUPTION in ${name}: matched "${m[0]}"`); failed++; }
  else console.log(`✓ ${name}: no corruption signature`);
}

function checkJs(name, code) {
  try { new vm.Script(code, { filename: name }); console.log(`✓ ${name}: JS parses`); }
  catch (e) { console.error(`✗ ${name}: SYNTAX ERROR — ${e.message}`); failed++; }
}

for (const f of ['cloud-sync.js', 'sw.js']) {
  const t = fs.readFileSync(`${root}/${f}`, 'utf8');
  checkCorruption(f, t);
  checkJs(f, t);
}

const html = fs.readFileSync(`${root}/index.html`, 'utf8');
checkCorruption('index.html', html);
// Extract inline (no src) <script> blocks
const re = /<script(?![^>]*\bsrc=)[^>]*>([\s\S]*?)<\/script>/gi;
let m, i = 0;
while ((m = re.exec(html))) {
  const code = m[1];
  if (code.trim()) { checkJs(`index.html <script #${++i}>`, code); }
}
console.log(`\nInline script blocks checked: ${i}`);
console.log(failed === 0 ? '\nALL CHECKS PASSED' : `\n${failed} CHECK(S) FAILED`);
process.exit(failed === 0 ? 0 : 1);
