import { createHmac } from "node:crypto";
import { writeFileSync } from "node:fs";
const [id, secret] = process.env.GHOST_ADMIN_API_KEY.split(":");
function tok(){const now=Math.floor(Date.now()/1000);const b=x=>Buffer.from(JSON.stringify(x)).toString("base64url");
const h=b({alg:"HS256",typ:"JWT",kid:id}),p=b({iat:now,exp:now+300,aud:"/admin/"});
return `${h}.${p}.${createHmac("sha256",Buffer.from(secret,"hex")).update(`${h}.${p}`).digest("base64url")}`;}
const root=process.env.GHOST_ADMIN_URL.replace(/\/+$/,"")+"/ghost/api/admin";
const all=[];let page=1;
while(true){
  const r=await fetch(`${root}/posts/?filter=status:published&limit=100&page=${page}&formats=plaintext&include=tags,authors&order=published_at%20desc`,{headers:{Authorization:`Ghost ${tok()}`,"Accept-Version":"v5.0"}});
  if(!r.ok){console.error(r.status,(await r.text()).slice(0,300));process.exit(1);}
  const j=await r.json();
  for(const p of j.posts) all.push({id:p.id,slug:p.slug,updated_at:p.updated_at,title:p.title,url:p.url,published_at:p.published_at,excerpt:p.custom_excerpt,tags:(p.tags||[]).map(t=>t.name),authors:(p.authors||[]).map(a=>a.name),plaintext:p.plaintext||""});
  console.error("page",page,"of",j.meta.pagination.pages);
  if(!j.meta.pagination.next)break;page++;
}
writeFileSync("all.json",JSON.stringify(all));
const nv=all.filter(p=>/nvidia/i.test(p.title+" "+p.plaintext));
writeFileSync("nvidia.json",JSON.stringify(nv,null,1));
console.log("total",all.length,"nvidia",nv.length);
