// Render the offline report HTML to a paginated A4 PDF with a running header
// and page numbers, driving the pre-installed Chromium via playwright-core.
const { chromium } = require('playwright-core');
const path = require('path');

const SRC = process.argv[2];   // absolute path to offline html
const OUT = process.argv[3];   // absolute path to output pdf
const HEADER_RIGHT = process.argv[4] || 'Quarterly Funding Report';  // running-header right label
// Locate the pre-installed Chromium (version-pinned dir may change between images).
const fs = require('fs');
function findChrome() {
  const envp = process.env.PDF_CHROME;
  if (envp && fs.existsSync(envp)) return envp;
  const base = '/opt/pw-browsers';
  try {
    const dir = fs.readdirSync(base).filter(d => /^chromium-\d+$/.test(d)).sort().pop();
    if (dir) {
      const p = `${base}/${dir}/chrome-linux/chrome`;
      if (fs.existsSync(p)) return p;
    }
  } catch (_) {}
  return `${base}/chromium-1194/chrome-linux/chrome`;
}
const CHROME = findChrome();

const headerTemplate = `
<style>
  #h { font-family: 'Public Sans', Arial, sans-serif; font-size: 7px; color: #775a0f;
       width: 100%; padding: 0 14mm; display: flex; justify-content: space-between;
       align-items: center; letter-spacing: 0.08em; text-transform: uppercase; }
  #h .r { color: #8a9099; }
</style>
<div id="h">
  <span>The French Tech Journal</span>
  <span class="r">${HEADER_RIGHT}</span>
</div>`;

const footerTemplate = `
<style>
  #f { font-family: 'Public Sans', Arial, sans-serif; font-size: 7px; color: #8a9099;
       width: 100%; padding: 0 14mm; display: flex; justify-content: space-between;
       align-items: center; letter-spacing: 0.04em; }
  #f .c { color: #114563; font-weight: 600; letter-spacing: 0.08em; text-transform: uppercase; }
</style>
<div id="f">
  <span>frenchtechjournal.com</span>
  <span class="c">Page <span class="pageNumber"></span> of <span class="totalPages"></span></span>
</div>`;

(async () => {
  const browser = await chromium.launch({ executablePath: CHROME, args: ['--no-sandbox'] });
  const page = await browser.newPage();
  await page.goto('file://' + SRC, { waitUntil: 'load', timeout: 60000 });
  // Ensure webfonts are ready, then let Chart.js finish its (animation-free) draw.
  await page.evaluate(() => document.fonts.ready);
  await page.waitForTimeout(1200);
  await page.emulateMedia({ media: 'print' });
  await page.pdf({
    path: OUT,
    format: 'A4',
    printBackground: true,
    displayHeaderFooter: true,
    headerTemplate,
    footerTemplate,
    margin: { top: '16mm', bottom: '14mm', left: '14mm', right: '14mm' },
  });
  await browser.close();
  console.log('wrote', OUT);
})().catch(e => { console.error(e); process.exit(1); });
