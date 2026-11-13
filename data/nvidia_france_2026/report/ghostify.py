import re,sys
src,out=sys.argv[1],sys.argv[2]
s=open(src).read()
css=re.search(r'<style>(.*?)</style>',s,re.S).group(1)
html_body=s[s.index('</style>')+8:]
head_links=''.join(re.findall(r'<link[^>]+>\n?',s[:s.index('<style>')]))
# drop dark-mode blocks and page-level rules
css=re.sub(r'@media \(prefers-color-scheme:dark\)\{:root:not\(\[data-theme="light"\]\)\{.*?\}\}','',css,flags=re.S)
css=re.sub(r':root\[data-theme="dark"\]\{.*?\}','',css,flags=re.S)
css=re.sub(r'html\{scroll-behavior:smooth\}','',css)
css=re.sub(r'@media \(prefers-reduced-motion:reduce\)\{html\{scroll-behavior:auto\}\}','',css)
css=re.sub(r'body::before\{[^}]*\}','',css)
css=re.sub(r'body\{([^}]*)\}',r'.nvf{\1}',css)
css=css.replace(':root{','.nvf{')
css=css.replace('top:env(safe-area-inset-top,0px)','top:0')
css=re.sub(r'/\*.*?\*/','',css,flags=re.S)
def prefix(block):
    res=[];i=0
    while i<len(block):
        if block[i].isspace(): i+=1; continue
        if block.startswith('@media',i):
            j=block.index('{',i); depth=1; k=j+1
            while depth:
                depth+= {'{':1,'}':-1}.get(block[k],0); k+=1
            res.append(block[i:j]+'{'+prefix(block[j+1:k-1])+'}'); i=k; continue
        j=block.index('{',i); k=block.index('}',j)
        sels=[x.strip() for x in block[i:j].split(',')]
        ps=[x if x.startswith('.nvf') and (x=='.nvf' or x.startswith('.nvf ') or x.startswith('.nvf{')) else '.nvf '+x for x in sels]
        res.append(','.join(ps)+'{'+block[j+1:k]+'}'); i=k+1
    return '\n'.join(res)
css=prefix(css)
guard="""/* Break out of the Ghost article column to 90% of the window, centred */
.nvf{width:90vw;max-width:90vw;margin-left:calc(50% - 45vw);margin-right:calc(50% - 45vw);box-sizing:border-box;color-scheme:light;font-size:15px;line-height:1.55;text-align:left}
.nvf *,.nvf *::before,.nvf *::after{box-sizing:border-box}
.nvf .wrap{max-width:1400px}
/* Neutralise common Ghost theme styles inside the embed */
.nvf h1,.nvf h2,.nvf h3,.nvf h4,.nvf p,.nvf ol,.nvf ul,.nvf blockquote,.nvf figure{margin:0}
.nvf h1,.nvf h2,.nvf h3,.nvf h4{color:inherit;letter-spacing:normal;text-transform:none;font-style:normal}
.nvf table{display:table;background:none;border-radius:0;white-space:normal;overflow:visible;max-width:none}
.nvf th,.nvf td{background-image:none}
.nvf a{box-shadow:none}
.nvf blockquote::before{content:none}
.nvf section{scroll-margin-top:80px}
"""
html_body=html_body.replace('<div class="wrap">','<div class="nvf"><div class="wrap">',1)
idx=html_body.index('<script>')
html_body=html_body[:idx]+'</div>\n'+html_body[idx:]
open(out,'w').write('<!-- NVIDIA in France: Ghost HTML-card embed. Paste everything into one HTML card. -->\n'+head_links+'<style>\n'+guard+css+'\n</style>\n'+html_body)
print(len(css))
