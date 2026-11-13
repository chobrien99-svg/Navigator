const fs=require('fs');const tc=require(process.argv[2]+'/package/dist/topojson-client.js');
const topo=JSON.parse(fs.readFileSync(process.argv[2]+'/package/countries-50m.json'));
const f=tc.feature(topo,topo.objects.countries).features.find(x=>x.id==='250');
const W=600,H=620, lon0=-5.3,lon1=9.8,lat0=41.2,lat1=51.3, k=Math.cos(46.5*Math.PI/180);
const sx=(W-40)/((lon1-lon0)*k), sy=(H-40)/(lat1-lat0), s=Math.min(sx,sy);
const P=([lo,la])=>[20+(lo-lon0)*k*s, 20+(lat1-la)*s];
let d='';
const polys=f.geometry.type==='Polygon'?[f.geometry.coordinates]:f.geometry.coordinates;
for(const poly of polys){const ring=poly[0]; if(!ring.every(([lo,la])=>lo>-6&&lo<10&&la>41&&la<52))continue;
 let last=null;ring.forEach((c,i)=>{const [x,y]=P(c);const pt=[x.toFixed(1),y.toFixed(1)];if(last&&Math.hypot(x-last[0],y-last[1])<1.2&&i<ring.length-1)return;last=[x,y];d+=(i===0?'M':'L')+pt[0]+' '+pt[1];});d+='Z';}
const places=JSON.parse(fs.readFileSync('../places.json'));
const pts=places.map(p=>({...p,xy:P([p.lon,p.lat]).map(v=>+v.toFixed(1))}));
fs.writeFileSync('../map_out.json',JSON.stringify({W,H,d,pts}));
console.log(d.length, pts.length);
