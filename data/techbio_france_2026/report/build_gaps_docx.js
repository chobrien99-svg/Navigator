const fs=require('fs');
const {Document,Packer,Paragraph,TextRun,HeadingLevel,Table,TableRow,TableCell,WidthType,ShadingType,BorderStyle,AlignmentType,LevelFormat,Footer,PageNumber}=require('docx');
const md=fs.readFileSync(process.argv[2],'utf8').split('\n');
const ACC='0E6B5C', INK='14201D', GREY='5B6662';
function runs(text,opts={}){ // **bold** inline
  const out=[]; const parts=text.split(/(\*\*[^*]+\*\*)/);
  for(const p of parts){ if(!p) continue;
    if(p.startsWith('**')) out.push(new TextRun({text:p.slice(2,-2),bold:true,...opts}));
    else out.push(new TextRun({text:p,...opts})); }
  return out;
}
const children=[]; let tableRows=null;
const border={style:BorderStyle.SINGLE,size:4,color:'D5DCD9'};
const borders={top:border,bottom:border,left:border,right:border};
const W=[3600,3000,2426]; // sums to 9026 (A4 with 1" margins)
function flushTable(){
  if(!tableRows) return;
  const rows=tableRows.filter(r=>!/^\|\s*-/.test(r)).map(r=>r.split('|').slice(1,-1).map(c=>c.trim()));
  children.push(new Table({width:{size:9026,type:WidthType.DXA},columnWidths:W,rows:rows.map((cells,i)=>new TableRow({tableHeader:i===0,children:cells.map((c,j)=>new TableCell({borders,width:{size:W[j],type:WidthType.DXA},margins:{top:60,bottom:60,left:100,right:100},
    shading:i===0?{fill:'E8F1EF',type:ShadingType.CLEAR,color:'auto'}:undefined,
    children:[new Paragraph({children:[new TextRun({text:c,bold:i===0,size:19})]})]}))}))}));
  children.push(new Paragraph({spacing:{after:120},children:[]}));
  tableRows=null;
}
for(const line of md){
  if(line.startsWith('|')){ (tableRows=tableRows||[]).push(line); continue; } else flushTable();
  if(!line.trim()) continue;
  if(line.startsWith('# ')) children.push(new Paragraph({heading:HeadingLevel.TITLE,children:[new TextRun(line.slice(2))]}));
  else if(line.startsWith('## ')) children.push(new Paragraph({heading:HeadingLevel.HEADING_1,children:[new TextRun(line.slice(3))]}));
  else if(line.startsWith('- ')) children.push(new Paragraph({numbering:{reference:'bul',level:0},spacing:{after:80},children:runs(line.slice(2))}));
  else if(line.startsWith('French Tech Journal /')) children.push(new Paragraph({spacing:{after:240},border:{bottom:{style:BorderStyle.SINGLE,size:6,color:ACC,space:6}},children:[new TextRun({text:line,color:GREY,size:19})]}));
  else children.push(new Paragraph({spacing:{after:120},children:runs(line)}));
}
flushTable();
const doc=new Document({
  creator:'French Tech Journal', title:'French TechBio Funding Map: data we could not confirm',
  styles:{default:{document:{run:{font:'Arial',size:21,color:INK}}},
    paragraphStyles:[
      {id:'Title',name:'Title',basedOn:'Normal',run:{font:'Arial',size:40,bold:true,color:INK},paragraph:{spacing:{before:0,after:120},keepNext:true}},
      {id:'Heading1',name:'Heading 1',basedOn:'Normal',next:'Normal',quickFormat:true,run:{font:'Arial',size:28,bold:true,color:ACC},paragraph:{spacing:{before:320,after:120},keepNext:true,outlineLevel:0}}]},
  numbering:{config:[{reference:'bul',levels:[{level:0,format:LevelFormat.BULLET,text:'•',alignment:AlignmentType.LEFT,style:{paragraph:{indent:{left:360,hanging:260}}}}]}]},
  sections:[{properties:{page:{margin:{top:1440,bottom:1440,left:1440,right:1440}}},
    footers:{default:new Footer({children:[new Paragraph({alignment:AlignmentType.RIGHT,children:[new TextRun({text:'French TechBio Funding Map · data gaps · page ',size:16,color:GREY}),new TextRun({children:[PageNumber.CURRENT],size:16,color:GREY})]})]})},
    children}]});
Packer.toBuffer(doc).then(b=>fs.writeFileSync(process.argv[3],b));
