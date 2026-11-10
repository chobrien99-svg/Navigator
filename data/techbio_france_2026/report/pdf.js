const {chromium}=require('playwright');const fs=require('fs');
(async()=>{const b=await chromium.launch();const p=await b.newPage({colorScheme:'light'});
const html=fs.readFileSync(process.argv[2],'utf8');
const printCss=`<style>
@page{size:A4;margin:16mm 14mm 18mm}
body{padding:0!important;background:#fff!important;font-size:10.5pt}
:root{--bg:#fff;--surface:#fff}
.wrap{max-width:none;gap:26px}
.controls,.tip{display:none!important}
.tbl{max-height:none!important;overflow:visible!important}
th{position:static!important}
details{border:0}details summary{list-style:none;padding:0 0 8px;font:600 1.3rem var(--display);border:0!important}
details summary::-webkit-details-marker{display:none}
details>div{padding:0!important}
.panel,.tiles,.finding,tr,.two>*{break-inside:avoid}
h2,h3{break-after:avoid}
#h-all{break-before:page}
.tiles{grid-template-columns:repeat(4,minmax(0,1fr))!important}
.two{grid-template-columns:minmax(0,1fr) minmax(0,1fr)!important;gap:14px}
.tile b{font-size:1.6rem}
.panel{padding:14px}
.tbl table{font-size:8.5pt}
th,td{padding:5px 8px}
#t-all{font-size:7.4pt;table-layout:fixed}
#t-all td,#t-all th{padding:4px 5px}
#t-all th:nth-child(1){width:13%}#t-all th:nth-child(2){width:14%}#t-all th:nth-child(3){width:11%}
#t-all th:nth-child(4){width:8%}#t-all th:nth-child(5){width:8%}#t-all th:nth-child(6){width:6%}#t-all th:nth-child(7){width:11%}
#t-all th{letter-spacing:.02em}
#t-all td:last-child{min-width:0!important}
#t-all .sw{margin-right:4px}
#t-sci{font-size:7.6pt;table-layout:fixed}
#t-sci td,#t-sci th{padding:4px 6px}
#t-sci th{letter-spacing:.02em}
#t-sci th:nth-child(1){width:16%}#t-sci th:nth-child(2){width:35%}#t-sci th:nth-child(3){width:24%}#t-sci th:nth-child(4){width:11%}#t-sci th:nth-child(5){width:14%}
#t-sci td:last-child{white-space:normal!important}
#t-eu,#t-court{font-size:8pt}#t-eu td,#t-eu th,#t-court td,#t-court th{padding:4px 6px}
.finding{padding:10px 0}
</style>`;
await p.setContent('<!doctype html><html lang="en"><head><meta charset="utf-8"></head><body>'+html+printCss+'</body></html>',{waitUntil:'networkidle'});
await p.evaluate(()=>{document.querySelectorAll('details').forEach(d=>d.open=true);document.querySelector('details summary').textContent='Data gaps and method';
 const H2=document.querySelectorAll('#t-sci th');['Company','Public research link','Patent co-owners','Families','Prizes'].forEach((t,i)=>H2[i].textContent=t);const H=document.querySelectorAll('#t-all th');['Company','Segment','Base','Founded','Rounds','€M','Stage','Investors'].forEach((t,i)=>H[i].textContent=t);const m=document.querySelector('.meta');m.textContent+=' · Interactive version: https://claude.ai/artifact/HP1GyrsYouAdUHGaZdp54A (private unless shared)';});
await p.evaluate(()=>document.fonts.ready);
const fonts=await p.evaluate(()=>[...document.fonts].filter(f=>f.status==='loaded').map(f=>f.family));
console.log('fonts loaded',[...new Set(fonts)]);
await p.pdf({path:process.argv[3],format:'A4',printBackground:true,displayHeaderFooter:true,
 headerTemplate:'<div></div>',
 footerTemplate:'<div style="font:8px Helvetica,Arial,sans-serif;color:#77817d;width:100%;padding:0 14mm;display:flex;justify-content:space-between"><span>French TechBio Funding Map · Navigator data as of 10 November 2026</span><span><span class="pageNumber"></span> / <span class="totalPages"></span></span></div>',
 margin:{top:'16mm',bottom:'18mm',left:'14mm',right:'14mm'}});
await b.close()})();
