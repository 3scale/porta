var hljs=new function(){function e(e){return e.replace(/&/gm,"&amp;").replace(/</gm,"&lt;")}function t(e){for(var t=0;t<e.childNodes.length;t++){var n=e.childNodes[t];if(n.nodeName=="CODE")return n;if(n.nodeType!=3||!n.nodeValue.match(/\s+/))break}}function r(e,t){var i="";for(var s=0;s<e.childNodes.length;s++)if(e.childNodes[s].nodeType==3){var o=e.childNodes[s].nodeValue;t&&(o=o.replace(/\n/g,"")),i+=o}else e.childNodes[s].nodeName=="BR"?i+="\n":i+=r(e.childNodes[s]);return n&&(i=i.replace(/\r/g,"\n")),i}function i(e){var t=e.className.split(/\s+/);t=t.concat(e.parentNode.className.split(/\s+/));for(var n=0;n<t.length;n++){var r=t[n].replace(/^language-/,"");if(d[r]||r=="no-highlight")return r}}function s(e){var t=[];return function n(e,r){for(var i=0;i<e.childNodes.length;i++)e.childNodes[i].nodeType==3?r+=e.childNodes[i].nodeValue.length:e.childNodes[i].nodeName=="BR"?r+=1:e.childNodes[i].nodeType==1&&(t.push({event:"start",offset:r,node:e.childNodes[i]}),r=n(e.childNodes[i],r),t.push({event:"stop",offset:r,node:e.childNodes[i]}));return r}(e,0),t}function o(t,n,r){function u(){return t.length&&n.length?t[0].offset!=n[0].offset?t[0].offset<n[0].offset?t:n:n[0].event=="start"?t:n:t.length?t:n}function a(t){var n="<"+t.nodeName.toLowerCase();for(var r=0;r<t.attributes.length;r++){var i=t.attributes[r];n+=" "+i.nodeName.toLowerCase(),i.value!==undefined&&i.value!==!1&&i.value!==null&&(n+='="'+e(i.value)+'"')}return n+">"}var i=0,s="",o=[];while(t.length||n.length){var f=u().splice(0,1)[0];s+=e(r.substr(i,f.offset-i)),i=f.offset;if(f.event=="start")s+=a(f.node),o.push(f.node);else if(f.event=="stop"){var l,c=o.length;do c--,l=o[c],s+="</"+l.nodeName.toLowerCase()+">";while(l!=f.node);o.splice(c,1);while(c<o.length)s+=a(o[c]),c++}}return s+e(r.substr(i))}function u(e){function t(t,n){return RegExp(t,"m"+(e.cI?"i":"")+(n?"g":""))}function n(e,r){if(e.compiled)return;e.compiled=!0;var i=[];if(e.k){var s={};function o(e,t){var n=t.split(" ");for(var r=0;r<n.length;r++){var o=n[r].split("|");s[o[0]]=[e,o[1]?Number(o[1]):1],i.push(o[0])}}e.lR=t(e.l||hljs.IR,!0);if(typeof e.k=="string")o("keyword",e.k);else for(var u in e.k){if(!e.k.hasOwnProperty(u))continue;o(u,e.k[u])}e.k=s}r&&(e.bWK&&(e.b="\\b("+i.join("|")+")\\s"),e.bR=t(e.b?e.b:"\\B|\\b"),!e.e&&!e.eW&&(e.e="\\B|\\b"),e.e&&(e.eR=t(e.e)),e.tE=e.e||"",e.eW&&r.tE&&(e.tE+=(e.e?"|":"")+r.tE)),e.i&&(e.iR=t(e.i)),e.r===undefined&&(e.r=1),e.c||(e.c=[]);for(var a=0;a<e.c.length;a++)e.c[a]=="self"&&(e.c[a]=e),n(e.c[a],e);e.starts&&n(e.starts,r);var f=[];for(var a=0;a<e.c.length;a++)f.push(e.c[a].b);e.tE&&f.push(e.tE),e.i&&f.push(e.i),e.t=f.length?t(f.join("|"),!0):null}n(e)}function a(t,n){function r(e,t){for(var n=0;n<t.c.length;n++){var r=t.c[n].bR.exec(e);if(r&&r.index==0)return t.c[n]}}function i(e,t){if(w[e].e&&w[e].eR.test(t))return 1;if(w[e].eW){var n=i(e-1,t);return n?n+1:0}return 0}function s(e,t){return t.i&&t.iR.test(e)}function o(e,t){var n=w[w.length-1];if(n.t)return n.t.lastIndex=t,n.t.exec(e)}function l(e,t){var n=b.cI?t[0].toLowerCase():t[0],r=e.k[n];return r&&r instanceof Array?r:!1}function c(t,n){t=e(t);if(!n.k)return t;var r="",i=0;n.lR.lastIndex=0;var s=n.lR.exec(t);while(s){r+=t.substr(i,s.index-i);var o=l(n,s);o?(S+=o[1],r+='<span class="'+o[0]+'">'+s[0]+"</span>"):r+=s[0],i=n.lR.lastIndex,s=n.lR.exec(t)}return r+t.substr(i)}function h(e,t){var n;return t.sL==""?n=f(e):n=a(t.sL,e),t.r>0&&(S+=n.keyword_count,E+=n.r),'<span class="'+n.language+'">'+n.value+"</span>"}function p(e,t){return t.sL&&d[t.sL]||t.sL==""?h(e,t):c(e,t)}function v(t,n){var r=t.cN?'<span class="'+t.cN+'">':"";t.rB?(x+=r,t.buffer=""):t.eB?(x+=e(n)+r,t.buffer=""):(x+=r,t.buffer=n),w.push(t),E+=t.r}function y(t,n){var o=w[w.length-1];if(n===undefined){x+=p(o.buffer+t,o);return}var u=r(n,o);if(u)return x+=p(o.buffer+t,o),v(u,n),u.rB;var a=i(w.length-1,n);if(a){var f=o.cN?"</span>":"";o.rE?x+=p(o.buffer+t,o)+f:o.eE?x+=p(o.buffer+t,o)+f+e(n):x+=p(o.buffer+t+n,o)+f;while(a>1)f=w[w.length-2].cN?"</span>":"",x+=f,a--,w.length--;var l=w[w.length-1];return w.length--,w[w.length-1].buffer="",l.starts&&v(l.starts,""),o.rE}if(s(n,o))throw"Illegal"}var b=d[t];u(b);var w=[b];b.buffer="";var E=0,S=0,x="";try{var T,N=0;for(;;){T=o(n,N);if(!T)break;var C=y(n.substr(N,T.index-N),T[0]);N=T.index+(C?0:T[0].length)}return y(n.substr(N),undefined),{r:E,keyword_count:S,value:x,language:t}}catch(k){if(k=="Illegal")return{r:0,keyword_count:0,value:e(n)};throw k}}function f(t){var n={keyword_count:0,r:0,value:e(t)},r=n;for(var i in d){if(!d.hasOwnProperty(i))continue;var s=a(i,t);s.language=i,s.keyword_count+s.r>r.keyword_count+r.r&&(r=s),s.keyword_count+s.r>n.keyword_count+n.r&&(r=n,n=s)}return r.language&&(n.second_best=r),n}function l(e,t,n){return t&&(e=e.replace(/^((<[^>]+>|\t)+)/gm,function(e,n,r,i){return n.replace(/\t/g,t)})),n&&(e=e.replace(/\n/g,"<br>")),e}function c(e,t,u){var c=r(e,u),h=i(e),p,d;if(h=="no-highlight")return;h?p=a(h,c):(p=f(c),h=p.language);var v=s(e);v.length&&(d=document.createElement("pre"),d.innerHTML=p.value,p.value=o(v,s(d),c)),p.value=l(p.value,t,u);var m=e.className;m.match("(\\s|^)(language-)?"+h+"(\\s|$)")||(m=m?m+" "+h:h);if(n&&e.tagName=="CODE"&&e.parentNode.tagName=="PRE"){d=e.parentNode;var g=document.createElement("div");g.innerHTML="<pre><code>"+p.value+"</code></pre>",e=g.firstChild.firstChild,g.firstChild.cN=d.cN,d.parentNode.replaceChild(g.firstChild,d)}else e.innerHTML=p.value;e.className=m,e.result={language:h,kw:p.keyword_count,re:p.r},p.second_best&&(e.second_best={language:p.second_best.language,kw:p.second_best.keyword_count,re:p.second_best.r})}function h(){if(h.called)return;h.called=!0;var e=document.getElementsByTagName("pre");for(var n=0;n<e.length;n++){var r=t(e[n]);r&&c(r,hljs.tabReplace)}}function p(){window.addEventListener?(window.addEventListener("DOMContentLoaded",h,!1),window.addEventListener("load",h,!1)):window.attachEvent?window.attachEvent("onload",h):window.onload=h}var n=typeof navigator!="undefined"&&/MSIE [678]/.test(navigator.userAgent),d={};this.LANGUAGES=d,this.highlight=a,this.highlightAuto=f,this.fixMarkup=l,this.highlightBlock=c,this.initHighlighting=h,this.initHighlightingOnLoad=p,this.IR="[a-zA-Z][a-zA-Z0-9_]*",this.UIR="[a-zA-Z_][a-zA-Z0-9_]*",this.NR="\\b\\d+(\\.\\d+)?",this.CNR="(\\b0[xX][a-fA-F0-9]+|(\\b\\d+(\\.\\d*)?|\\.\\d+)([eE][-+]?\\d+)?)",this.BNR="\\b(0b[01]+)",this.RSR="!|!=|!==|%|%=|&|&&|&=|\\*|\\*=|\\+|\\+=|,|\\.|-|-=|/|/=|:|;|<|<<|<<=|<=|=|==|===|>|>=|>>|>>=|>>>|>>>=|\\?|\\[|\\{|\\(|\\^|\\^=|\\||\\|=|\\|\\||~",this.BE={b:"\\\\[\\s\\S]",r:0},this.ASM={cN:"string",b:"'",e:"'",i:"\\n",c:[this.BE],r:0},this.QSM={cN:"string",b:'"',e:'"',i:"\\n",c:[this.BE],r:0},this.CLCM={cN:"comment",b:"//",e:"$"},this.CBLCLM={cN:"comment",b:"/\\*",e:"\\*/"},this.HCM={cN:"comment",b:"#",e:"$"},this.NM={cN:"number",b:this.NR,r:0},this.CNM={cN:"number",b:this.CNR,r:0},this.BNM={cN:"number",b:this.BNR,r:0},this.inherit=function(e,t){var n={};for(var r in e)n[r]=e[r];if(t)for(var r in t)n[r]=t[r];return n}};hljs.LANGUAGES.bash=function(e){var t="true false",n={cN:"variable",b:"\\$[a-zA-Z0-9_]+\\b"},r={cN:"variable",b:"\\${([^}]|\\\\})+}"},i={cN:"string",b:'"',e:'"',i:"\\n",c:[e.BE,n,r],r:0},s={cN:"string",b:"'",e:"'",c:[{b:"''"}],r:0},o={cN:"test_condition",b:"",e:"",c:[i,s,n,r],k:{literal:t},r:0};return{k:{keyword:"if then else fi for break continue while in do done echo exit return set declare",literal:t},c:[{cN:"shebang",b:"(#!\\/bin\\/bash)|(#!\\/bin\\/sh)",r:10},n,r,e.HCM,i,s,e.inherit(o,{b:"\\[ ",e:" \\]",r:0}),e.inherit(o,{b:"\\[\\[ ",e:" \\]\\]"})]}}(hljs),hljs.LANGUAGES.coffeescript=function(e){var t={keyword:"in if for while finally new do return else break catch instanceof throw try this switch continue typeof delete debugger class extends superthen unless until loop of by when and or is isnt not",literal:"true false null undefined yes no on off ",reserved:"case default function var void with const let enum export import native __hasProp __extends __slice __bind __indexOf"},n="[A-Za-z$_][0-9A-Za-z$_]*",r={cN:"subst",b:"#\\{",e:"}",k:t,c:[e.CNM,e.BNM]},i={cN:"string",b:'"',e:'"',r:0,c:[e.BE,r]},s={cN:"string",b:'"""',e:'"""',c:[e.BE,r]},o={cN:"comment",b:"###",e:"###"},u={cN:"regexp",b:"///",e:"///",c:[e.HCM]},a={cN:"regexp",b:"//[gim]*"},f={cN:"regexp",b:"/\\S(\\\\.|[^\\n])*/[gim]*"},l={cN:"function",b:n+"\\s*=\\s*(\\(.+\\))?\\s*[-=]>",rB:!0,c:[{cN:"title",b:n},{cN:"params",b:"\\(",e:"\\)"}]},c={b:"`",e:"`",eB:!0,eE:!0,sL:"javascript"};return{k:t,c:[e.CNM,e.BNM,e.ASM,s,i,o,e.HCM,u,a,f,c,l]}}(hljs),hljs.LANGUAGES.cs=function(e){return{k:"abstract as base bool break byte case catch char checked class const continue decimal default delegate do double else enum event explicit extern false finally fixed float for foreach goto if implicit in int interface internal is lock long namespace new null object operator out override params private protected public readonly ref return sbyte sealed short sizeof stackalloc static string struct switch this throw true try typeof uint ulong unchecked unsafe ushort using virtual volatile void while ascending descending from get group into join let orderby partial select set value var where yield",c:[{cN:"comment",b:"///",e:"$",rB:!0,c:[{cN:"xmlDocTag",b:"///|<!--|-->"},{cN:"xmlDocTag",b:"</?",e:">"}]},e.CLCM,e.CBLCLM,{cN:"preprocessor",b:"#",e:"$",k:"if else elif endif define undef warning error line region endregion pragma checksum"},{cN:"string",b:'@"',e:'"',c:[{b:'""'}]},e.ASM,e.QSM,e.CNM]}}(hljs),hljs.LANGUAGES.css=function(e){var t={cN:"function",b:e.IR+"\\(",e:"\\)",c:[e.NM,e.ASM,e.QSM]};return{cI:!0,i:"[=/|']",c:[e.CBLCLM,{cN:"id",b:"\\#[A-Za-z0-9_-]+"},{cN:"class",b:"\\.[A-Za-z0-9_-]+",r:0},{cN:"attr_selector",b:"\\[",e:"\\]",i:"$"},{cN:"pseudo",b:":(:)?[a-zA-Z0-9\\_\\-\\+\\(\\)\\\"\\']+"},{cN:"at_rule",b:"@(font-face|page)",l:"[a-z-]+",k:"font-face page"},{cN:"at_rule",b:"@",e:"[{;]",eE:!0,k:"import page media charset",c:[t,e.ASM,e.QSM,e.NM]},{cN:"tag",b:e.IR,r:0},{cN:"rules",b:"{",e:"}",i:"[^\\s]",r:0,c:[e.CBLCLM,{cN:"rule",b:"[^\\s]",rB:!0,e:";",eW:!0,c:[{cN:"attribute",b:"[A-Z\\_\\.\\-]+",e:":",eE:!0,i:"[^\\s]",starts:{cN:"value",eW:!0,eE:!0,c:[t,e.NM,e.QSM,e.ASM,e.CBLCLM,{cN:"hexcolor",b:"\\#[0-9A-F]+"},{cN:"important",b:"!important"}]}}]}]}]}}(hljs),hljs.LANGUAGES.diff=function(e){return{cI:!0,c:[{cN:"chunk",b:"^\\@\\@ +\\-\\d+,\\d+ +\\+\\d+,\\d+ +\\@\\@$",r:10},{cN:"chunk",b:"^\\*\\*\\* +\\d+,\\d+ +\\*\\*\\*\\*$",r:10},{cN:"chunk",b:"^\\-\\-\\- +\\d+,\\d+ +\\-\\-\\-\\-$",r:10},{cN:"header",b:"Index: ",e:"$"},{cN:"header",b:"=====",e:"=====$"},{cN:"header",b:"^\\-\\-\\-",e:"$"},{cN:"header",b:"^\\*{3} ",e:"$"},{cN:"header",b:"^\\+\\+\\+",e:"$"},{cN:"header",b:"\\*{5}",e:"\\*{5}$"},{cN:"addition",b:"^\\+",e:"$"},{cN:"deletion",b:"^\\-",e:"$"},{cN:"change",b:"^\\!",e:"$"}]}}(hljs),hljs.LANGUAGES.xml=function(e){var t="[A-Za-z0-9\\._:-]+",n={eW:!0,c:[{cN:"attribute",b:t,r:0},{b:'="',rB:!0,e:'"',c:[{cN:"value",b:'"',eW:!0}]},{b:"='",rB:!0,e:"'",c:[{cN:"value",b:"'",eW:!0}]},{b:"=",c:[{cN:"value",b:"[^\\s/>]+"}]}]};return{cI:!0,c:[{cN:"pi",b:"<\\?",e:"\\?>",r:10},{cN:"doctype",b:"<!DOCTYPE",e:">",r:10,c:[{b:"\\[",e:"\\]"}]},{cN:"comment",b:"<!--",e:"-->",r:10},{cN:"cdata",b:"<\\!\\[CDATA\\[",e:"\\]\\]>",r:10},{cN:"tag",b:"<style(?=\\s|>|$)",e:">",k:{title:"style"},c:[n],starts:{e:"</style>",rE:!0,sL:"css"}},{cN:"tag",b:"<script(?=\\s|>|$)",e:">",k:{title:"script"},c:[n],starts:{e:"</script>",rE:!0,sL:"javascript"}},{b:"<%",e:"%>",sL:"vbscript"},{cN:"tag",b:"</?",e:"/?>",c:[{cN:"title",b:"[^ />]+"},n]}]}}(hljs),hljs.LANGUAGES.django=function(e){function t(e,t){return t==undefined||!e.cN&&t.cN=="tag"||e.cN=="value"}function n(e,r){var s={};for(var o in e){o!="contains"&&(s[o]=e[o]);var u=[];for(var a=0;e.c&&a<e.c.length;a++)u.push(n(e.c[a],e));t(e,r)&&(u=i.concat(u)),u.length&&(s.c=u)}return s}var r={cN:"filter",b:"\\|[A-Za-z]+\\:?",eE:!0,k:"truncatewords removetags linebreaksbr yesno get_digit timesince random striptags filesizeformat escape linebreaks length_is ljust rjust cut urlize fix_ampersands title floatformat capfirst pprint divisibleby add make_list unordered_list urlencode timeuntil urlizetrunc wordcount stringformat linenumbers slice date dictsort dictsortreversed default_if_none pluralize lower join center default truncatewords_html upper length phone2numeric wordwrap time addslashes slugify first escapejs force_escape iriencode last safe safeseq truncatechars localize unlocalize localtime utc timezone",c:[{cN:"argument",b:'"',e:'"'}]},i=[{cN:"template_comment",b:"{%\\s*comment\\s*%}",e:"{%\\s*endcomment\\s*%}"},{cN:"template_comment",b:"{#",e:"#}"},{cN:"template_tag",b:"{%",e:"%}",k:"comment endcomment load templatetag ifchanged endifchanged if endif firstof for endfor in ifnotequal endifnotequal widthratio extends include spaceless endspaceless regroup by as ifequal endifequal ssi now with cycle url filter endfilter debug block endblock else autoescape endautoescape csrf_token empty elif endwith static trans blocktrans endblocktrans get_static_prefix get_media_prefix plural get_current_language language get_available_languages get_current_language_bidi get_language_info get_language_info_list localize endlocalize localtime endlocaltime timezone endtimezone get_current_timezone",c:[r]},{cN:"variable",b:"{{",e:"}}",c:[r]}],s=n(e.LANGUAGES.xml);return s.cI=!0,s}(hljs),hljs.LANGUAGES.http=function(e){return{i:"\\S",c:[{cN:"status",b:"^HTTP/[0-9\\.]+",e:"$",c:[{cN:"number",b:"\\b\\d{3}\\b"}]},{cN:"request",b:"^[A-Z]+ (.*?) HTTP/[0-9\\.]+$",rB:!0,e:"$",c:[{cN:"string",b:" ",e:" ",eB:!0,eE:!0}]},{cN:"attribute",b:"^\\w",e:": ",eE:!0,i:"\\n|\\s|=",starts:{cN:"string",e:"$"}},{b:"\\n\\n",starts:{sL:"",eW:!0}}]}}(hljs),hljs.LANGUAGES.java=function(e){return{k:"false synchronized int abstract float private char boolean static null if const for true while long throw strictfp finally protected import native final return void enum else break transient new catch instanceof byte super volatile case assert short package default double public try this switch continue throws",c:[{cN:"javadoc",b:"/\\*\\*",e:"\\*/",c:[{cN:"javadoctag",b:"@[A-Za-z]+"}],r:10},e.CLCM,e.CBLCLM,e.ASM,e.QSM,{cN:"class",bWK:!0,e:"{",k:"class interface",i:":",c:[{bWK:!0,k:"extends implements",r:10},{cN:"title",b:e.UIR}]},e.CNM,{cN:"annotation",b:"@[A-Za-z]+"}]}}(hljs),hljs.LANGUAGES.javascript=function(e){return{k:{keyword:"in if for while finally var new function do return void else break catch instanceof with throw case default try this switch continue typeof delete let yield const",literal:"true false null undefined NaN Infinity"},c:[e.ASM,e.QSM,e.CLCM,e.CBLCLM,e.CNM,{b:"("+e.RSR+"|\\b(case|return|throw)\\b)\\s*",k:"return throw case",c:[e.CLCM,e.CBLCLM,{cN:"regexp",b:"/",e:"/[gim]*",c:[{b:"\\\\/"}]}],r:0},{cN:"function",bWK:!0,e:"{",k:"function",c:[{cN:"title",b:"[A-Za-z$_][0-9A-Za-z$_]*"},{cN:"params",b:"\\(",e:"\\)",c:[e.CLCM,e.CBLCLM],i:"[\"'\\(]"}],i:"\\[|%"}]}}(hljs),hljs.LANGUAGES.json=function(e){var t={literal:"true false null"},n=[e.QSM,e.CNM],r={cN:"value",e:",",eW:!0,eE:!0,c:n,k:t},i={b:"{",e:"}",c:[{cN:"attribute",b:'\\s*"',e:'"\\s*:\\s*',eB:!0,eE:!0,c:[e.BE],i:"\\n",starts:r}],i:"\\S"},s={b:"\\[",e:"\\]",c:[e.inherit(r,{cN:null})],i:"\\S"};return n.splice(n.length,0,i,s),{c:n,k:t,i:"\\S"}}(hljs),hljs.LANGUAGES.lua=function(e){var t="\\[=*\\[",n="\\]=*\\]",r={b:t,e:n,c:["self"]},i=[{cN:"comment",b:"--(?!"+t+")",e:"$"},{cN:"comment",b:"--"+t,e:n,c:[r],r:10}];return{l:e.UIR,k:{keyword:"and break do else elseif end false for if in local nil not or repeat return then true until while",built_in:"_G _VERSION assert collectgarbage dofile error getfenv getmetatable ipairs load loadfile loadstring module next pairs pcall print rawequal rawget rawset require select setfenv setmetatable tonumber tostring type unpack xpcall coroutine debug io math os package string table"},c:i.concat([{cN:"function",bWK:!0,e:"\\)",k:"function",c:[{cN:"title",b:"([_a-zA-Z]\\w*\\.)*([_a-zA-Z]\\w*:)?[_a-zA-Z]\\w*"},{cN:"params",b:"\\(",eW:!0,c:i}].concat(i)},e.CNM,e.ASM,e.QSM,{cN:"string",b:t,e:n,c:[r],r:10}])}}(hljs),hljs.LANGUAGES.markdown=function(e){return{cI:!0,c:[{cN:"header",b:"^#{1,3}",e:"$"},{cN:"header",b:"^.+?\\n[=-]{2,}$"},{b:"<",e:">",sL:"xml",r:0},{cN:"bullet",b:"^([*+-]|(\\d+\\.))\\s+"},{cN:"strong",b:"[*_]{2}.+?[*_]{2}"},{cN:"emphasis",b:"\\*.+?\\*"},{cN:"emphasis",b:"_.+?_",r:0},{cN:"blockquote",b:"^>\\s+",e:"$"},{cN:"code",b:"`.+?`"},{cN:"code",b:"^    ",e:"$",r:0},{cN:"horizontal_rule",b:"^-{3,}",e:"$"},{b:"\\[.+?\\]\\(.+?\\)",rB:!0,c:[{cN:"link_label",b:"\\[.+\\]"},{cN:"link_url",b:"\\(",e:"\\)",eB:!0,eE:!0}]}]}}(hljs),hljs.LANGUAGES.nginx=function(e){var t=[{cN:"variable",b:"\\$\\d+"},{cN:"variable",b:"\\${",e:"}"},{cN:"variable",b:"[\\$\\@]"+e.UIR}],n={eW:!0,l:"[a-z/_]+",k:{built_in:"on off yes no true false none blocked debug info notice warn error crit select break last permanent redirect kqueue rtsig epoll poll /dev/poll"},r:0,i:"=>",c:[e.HCM,{cN:"string",b:'"',e:'"',c:[e.BE].concat(t),r:0},{cN:"string",b:"'",e:"'",c:[e.BE].concat(t),r:0},{cN:"url",b:"([a-z]+):/",e:"\\s",eW:!0,eE:!0},{cN:"regexp",b:"\\s\\^",e:"\\s|{|;",rE:!0,c:[e.BE].concat(t)},{cN:"regexp",b:"~\\*?\\s+",e:"\\s|{|;",rE:!0,c:[e.BE].concat(t)},{cN:"regexp",b:"\\*(\\.[a-z\\-]+)+",c:[e.BE].concat(t)},{cN:"regexp",b:"([a-z\\-]+\\.)+\\*",c:[e.BE].concat(t)},{cN:"number",b:"\\b\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}(:\\d{1,5})?\\b"},{cN:"number",b:"\\b\\d+[kKmMgGdshdwy]*\\b",r:0}].concat(t)};return{c:[e.HCM,{b:e.UIR+"\\s",e:";|{",rB:!0,c:[{cN:"title",b:e.UIR,starts:n}]}],i:"[^\\s\\}]"}}(hljs),hljs.LANGUAGES.perl=function(e){var t="getpwent getservent quotemeta msgrcv scalar kill dbmclose undef lc ma syswrite tr send umask sysopen shmwrite vec qx utime local oct semctl localtime readpipe do return format read sprintf dbmopen pop getpgrp not getpwnam rewinddir qqfileno qw endprotoent wait sethostent bless s|0 opendir continue each sleep endgrent shutdown dump chomp connect getsockname die socketpair close flock exists index shmgetsub for endpwent redo lstat msgctl setpgrp abs exit select print ref gethostbyaddr unshift fcntl syscall goto getnetbyaddr join gmtime symlink semget splice x|0 getpeername recv log setsockopt cos last reverse gethostbyname getgrnam study formline endhostent times chop length gethostent getnetent pack getprotoent getservbyname rand mkdir pos chmod y|0 substr endnetent printf next open msgsnd readdir use unlink getsockopt getpriority rindex wantarray hex system getservbyport endservent int chr untie rmdir prototype tell listen fork shmread ucfirst setprotoent else sysseek link getgrgid shmctl waitpid unpack getnetbyname reset chdir grep split require caller lcfirst until warn while values shift telldir getpwuid my getprotobynumber delete and sort uc defined srand accept package seekdir getprotobyname semop our rename seek if q|0 chroot sysread setpwent no crypt getc chown sqrt write setnetent setpriority foreach tie sin msgget map stat getlogin unless elsif truncate exec keys glob tied closedirioctl socket readlink eval xor readline binmode setservent eof ord bind alarm pipe atan2 getgrent exp time push setgrent gt lt or ne m|0",n={cN:"subst",b:"[$@]\\{",e:"\\}",k:t,r:10},r={cN:"variable",b:"\\$\\d"},i={cN:"variable",b:"[\\$\\%\\@\\*](\\^\\w\\b|#\\w+(\\:\\:\\w+)*|[^\\s\\w{]|{\\w+}|\\w+(\\:\\:\\w*)*)"},s=[e.BE,n,r,i],o={b:"->",c:[{b:e.IR},{b:"{",e:"}"}]},u={cN:"comment",b:"^(__END__|__DATA__)",e:"\\n$",r:5},a=[r,i,e.HCM,u,{cN:"comment",b:"^\\=\\w",e:"\\=cut",eW:!0},o,{cN:"string",b:"q[qwxr]?\\s*\\(",e:"\\)",c:s,r:5},{cN:"string",b:"q[qwxr]?\\s*\\[",e:"\\]",c:s,r:5},{cN:"string",b:"q[qwxr]?\\s*\\{",e:"\\}",c:s,r:5},{cN:"string",b:"q[qwxr]?\\s*\\|",e:"\\|",c:s,r:5},{cN:"string",b:"q[qwxr]?\\s*\\<",e:"\\>",c:s,r:5},{cN:"string",b:"qw\\s+q",e:"q",c:s,r:5},{cN:"string",b:"'",e:"'",c:[e.BE],r:0},{cN:"string",b:'"',e:'"',c:s,r:0},{cN:"string",b:"`",e:"`",c:[e.BE]},{cN:"string",b:"{\\w+}",r:0},{cN:"string",b:"-?\\w+\\s*\\=\\>",r:0},{cN:"number",b:"(\\b0[0-7_]+)|(\\b0x[0-9a-fA-F_]+)|(\\b[1-9][0-9_]*(\\.[0-9_]+)?)|[0_]\\b",r:0},{b:"("+e.RSR+"|\\b(split|return|print|reverse|grep)\\b)\\s*",k:"split return print reverse grep",r:0,c:[e.HCM,u,{cN:"regexp",b:"(s|tr|y)/(\\\\.|[^/])*/(\\\\.|[^/])*/[a-z]*",r:10},{cN:"regexp",b:"(m|qr)?/",e:"/[a-z]*",c:[e.BE],r:0}]},{cN:"sub",bWK:!0,e:"(\\s*\\(.*?\\))?[;{]",k:"sub",r:5},{cN:"operator",b:"-\\w\\b",r:0}];return n.c=a,o.c[1].c=a,{k:t,c:a}}(hljs),hljs.LANGUAGES.php=function(e){var t={cN:"variable",b:"\\$+[a-zA-Z_-Ã¿][a-zA-Z0-9_-Ã¿]*"},n=[e.inherit(e.ASM,{i:null}),e.inherit(e.QSM,{i:null}),{cN:"string",b:'b"',e:'"',c:[e.BE]},{cN:"string",b:"b'",e:"'",c:[e.BE]}],r=[e.CNM,e.BNM],i={cN:"title",b:e.UIR};return{cI:!0,k:"and include_once list abstract global private echo interface as static endswitch array null if endwhile or const for endforeach self var while isset public protected exit foreach throw elseif include __FILE__ empty require_once do xor return implements parent clone use __CLASS__ __LINE__ else break print eval new catch __METHOD__ case exception php_user_filter default die require __FUNCTION__ enddeclare final try this switch continue endfor endif declare unset true false namespace trait goto instanceof insteadof __DIR__ __NAMESPACE__ __halt_compiler",c:[e.CLCM,e.HCM,{cN:"comment",b:"/\\*",e:"\\*/",c:[{cN:"phpdoc",b:"\\s@[A-Za-z]+"}]},{cN:"comment",eB:!0,b:"__halt_compiler.+?;",eW:!0},{cN:"string",b:"<<<['\"]?\\w+['\"]?$",e:"^\\w+;",c:[e.BE]},{cN:"preprocessor",b:"<\\?php",r:10},{cN:"preprocessor",b:"\\?>"},t,{cN:"function",bWK:!0,e:"{",k:"function",i:"\\$|\\[|%",c:[i,{cN:"params",b:"\\(",e:"\\)",c:["self",t,e.CBLCLM].concat(n).concat(r)}]},{cN:"class",bWK:!0,e:"{",k:"class",i:"[:\\(\\$]",c:[{bWK:!0,eW:!0,k:"extends",c:[i]},i]},{b:"=>"}].concat(n).concat(r)}}(hljs),hljs.LANGUAGES.python=function(e){var t=[{cN:"string",b:"(u|b)?r?'''",e:"'''",r:10},{cN:"string",b:'(u|b)?r?"""',e:'"""',r:10},{cN:"string",b:"(u|r|ur)'",e:"'",c:[e.BE],r:10},{cN:"string",b:'(u|r|ur)"',e:'"',c:[e.BE],r:10},{cN:"string",b:"(b|br)'",e:"'",c:[e.BE]},{cN:"string",b:'(b|br)"',e:'"',c:[e.BE]}].concat([e.ASM,e.QSM]),n={cN:"title",b:e.UIR},r={cN:"params",b:"\\(",e:"\\)",c:["self",e.CNM].concat(t)},i={bWK:!0,e:":",i:"[${=;\\n]",c:[n,r],r:10};return{k:{keyword:"and elif is global as in if from raise for except finally print import pass return exec else break not with class assert yield try while continue del or def lambda nonlocal|10",built_in:"None True False Ellipsis NotImplemented"},i:"(</|->|\\?)",c:t.concat([e.HCM,e.inherit(i,{cN:"function",k:"def"}),e.inherit(i,{cN:"class",k:"class"}),e.CNM,{cN:"decorator",b:"@",e:"$"},{b:"\\b(print|exec)\\("}])}}(hljs),hljs.LANGUAGES.ruby=function(e){var t="[a-zA-Z_][a-zA-Z0-9_]*(\\!|\\?)?",n="[a-zA-Z_]\\w*[!?=]?|[-+~]\\@|<<|>>|=~|===?|<=>|[<>]=?|\\*\\*|[-/+%^&*~`|]|\\[\\]=?",r={keyword:"and false then defined module in return redo if BEGIN retry end for true self when next until do begin unless END rescue nil else break undef not super class case require yield alias while ensure elsif or include"},i={cN:"yardoctag",b:"@[A-Za-z]+"},s=[{cN:"comment",b:"#",e:"$",c:[i]},{cN:"comment",b:"^\\=begin",e:"^\\=end",c:[i],r:10},{cN:"comment",b:"^__END__",e:"\\n$"}],o={cN:"subst",b:"#\\{",e:"}",l:t,k:r},u=[e.BE,o],a=[{cN:"string",b:"'",e:"'",c:u,r:0},{cN:"string",b:'"',e:'"',c:u,r:0},{cN:"string",b:"%[qw]?\\(",e:"\\)",c:u},{cN:"string",b:"%[qw]?\\[",e:"\\]",c:u},{cN:"string",b:"%[qw]?{",e:"}",c:u},{cN:"string",b:"%[qw]?<",e:">",c:u,r:10},{cN:"string",b:"%[qw]?/",e:"/",c:u,r:10},{cN:"string",b:"%[qw]?%",e:"%",c:u,r:10},{cN:"string",b:"%[qw]?-",e:"-",c:u,r:10},{cN:"string",b:"%[qw]?\\|",e:"\\|",c:u,r:10}],f={cN:"function",bWK:!0,e:" |$|;",k:"def",c:[{cN:"title",b:n,l:t,k:r},{cN:"params",b:"\\(",e:"\\)",l:t,k:r}].concat(s)},l=s.concat(a.concat([{cN:"class",bWK:!0,e:"$|;",k:"class module",c:[{cN:"title",b:"[A-Za-z_]\\w*(::\\w+)*(\\?|\\!)?",r:0},{cN:"inheritance",b:"<\\s*",c:[{cN:"parent",b:"("+e.IR+"::)?"+e.IR}]}].concat(s)},f,{cN:"constant",b:"(::)?(\\b[A-Z]\\w*(::)?)+",r:0},{cN:"symbol",b:":",c:a.concat([{b:t}]),r:0},{cN:"number",b:"(\\b0[0-7_]+)|(\\b0x[0-9a-fA-F_]+)|(\\b[1-9][0-9_]*(\\.[0-9_]+)?)|[0_]\\b",r:0},{cN:"number",b:"\\?\\w"},{cN:"variable",b:"(\\$\\W)|((\\$|\\@\\@?)(\\w+))"},{b:"("+e.RSR+")\\s*",c:s.concat([{cN:"regexp",b:"/",e:"/[a-z]*",i:"\\n",c:[e.BE]}]),r:0}]));return o.c=l,f.c[1].c=l,{l:t,k:r,c:l}}(hljs);


/* 3scale addition - stub to not brake old call to fancybox */
(function($) {
  $.fn.fancybox = $.fn.colorbox;

  $.fancybox = function(content){
    $.colorbox({html: content});
  }
  $.extend($.fancybox, {
    close: $.colorbox.close,
    resize: $.colorbox.resize,
    showActivity: $.colorbox,
    hideActivity: $.colorbox.close
  });
})(jQuery);
(function($, undefined) {

/**
 * Unobtrusive scripting adapter for jQuery
 *
 * Requires jQuery 1.6.0 or later.
 * https://github.com/rails/jquery-ujs

 * Uploading file using rails.js
 * =============================
 *
 * By default, browsers do not allow files to be uploaded via AJAX. As a result, if there are any non-blank file fields
 * in the remote form, this adapter aborts the AJAX submission and allows the form to submit through standard means.
 *
 * The `ajax:aborted:file` event allows you to bind your own handler to process the form submission however you wish.
 *
 * Ex:
 *     $('form').live('ajax:aborted:file', function(event, elements){
 *       // Implement own remote file-transfer handler here for non-blank file inputs passed in `elements`.
 *       // Returning false in this handler tells rails.js to disallow standard form submission
 *       return false;
 *     });
 *
 * The `ajax:aborted:file` event is fired when a file-type input is detected with a non-blank value.
 *
 * Third-party tools can use this hook to detect when an AJAX file upload is attempted, and then use
 * techniques like the iframe method to upload the file instead.
 *
 * Required fields in rails.js
 * ===========================
 *
 * If any blank required inputs (required="required") are detected in the remote form, the whole form submission
 * is canceled. Note that this is unlike file inputs, which still allow standard (non-AJAX) form submission.
 *
 * The `ajax:aborted:required` event allows you to bind your own handler to inform the user of blank required inputs.
 *
 * !! Note that Opera does not fire the form's submit event if there are blank required inputs, so this event may never
 *    get fired in Opera. This event is what causes other browsers to exhibit the same submit-aborting behavior.
 *
 * Ex:
 *     $('form').live('ajax:aborted:required', function(event, elements){
 *       // Returning false in this handler tells rails.js to submit the form anyway.
 *       // The blank required inputs are passed to this function in `elements`.
 *       return ! confirm("Would you like to submit the form with missing info?");
 *     });
 */

  // Cut down on the number if issues from people inadvertently including jquery_ujs twice
  // by detecting and raising an error when it happens.
  var alreadyInitialized = function() {
    var events = $._data(document, 'events');
    return events && events.click && $.grep(events.click, function(e) { return e.namespace === 'rails'; }).length;
  }

  if ( alreadyInitialized() ) {
    $.error('jquery-ujs has already been loaded!');
  }

  // Shorthand to make it a little easier to call public rails functions from within rails.js
  var rails;

  $.rails = rails = {
    // Link elements bound by jquery-ujs
    linkClickSelector: 'a[data-confirm], a[data-method], a[data-remote], a[data-disable-with]',

    // Select elements bound by jquery-ujs
    inputChangeSelector: 'select[data-remote], input[data-remote], textarea[data-remote]',

    // Form elements bound by jquery-ujs
    formSubmitSelector: 'form',

    // Form input elements bound by jquery-ujs
    formInputClickSelector: 'form input[type=submit], form input[type=image], form button[type=submit], form button:not([type])',

    // Form input elements disabled during form submission
    disableSelector: 'input[data-disable-with], button[data-disable-with], textarea[data-disable-with]',

    // Form input elements re-enabled after form submission
    enableSelector: 'input[data-disable-with]:disabled, button[data-disable-with]:disabled, textarea[data-disable-with]:disabled',

    // Form required input elements
    requiredInputSelector: 'input[name][required]:not([disabled]),textarea[name][required]:not([disabled])',

    // Form file input elements
    fileInputSelector: 'input:file',

    // Link onClick disable selector with possible reenable after remote submission
    linkDisableSelector: 'a[data-disable-with]',

    // Make sure that every Ajax request sends the CSRF token
    CSRFProtection: function(xhr) {
      var token = $('meta[name="csrf-token"]').attr('content');
      if (token) xhr.setRequestHeader('X-CSRF-Token', token);
    },

    // Triggers an event on an element and returns false if the event result is false
    fire: function(obj, name, data) {
      var event = $.Event(name);
      obj.trigger(event, data);
      return event.result !== false;
    },

    // Default confirm dialog, may be overridden with custom confirm dialog in $.rails.confirm
    confirm: function(message) {
      return confirm(message);
    },

    // Default ajax function, may be overridden with custom function in $.rails.ajax
    ajax: function(options) {
      return $.ajax(options);
    },

    // Default way to get an element's href. May be overridden at $.rails.href.
    href: function(element) {
      return element.attr('href');
    },

    // Submits "remote" forms and links with ajax
    handleRemote: function(element) {
      var method, url, data, elCrossDomain, crossDomain, withCredentials, dataType, options;

      if (rails.fire(element, 'ajax:before')) {
        elCrossDomain = element.data('cross-domain');
        crossDomain = elCrossDomain === undefined ? null : elCrossDomain;
        withCredentials = element.data('with-credentials') || null;
        dataType = element.data('type') || ($.ajaxSettings && $.ajaxSettings.dataType);

        if (element.is('form')) {
          method = element.attr('method');
          url = element.attr('action');
          data = element.serializeArray();
          // memoized value from clicked submit button
          var button = element.data('ujs:submit-button');
          if (button) {
            data.push(button);
            element.data('ujs:submit-button', null);
          }
        } else if (element.is(rails.inputChangeSelector)) {
          method = element.data('method');
          url = element.data('url');
          data = element.serialize();
          if (element.data('params')) data = data + "&" + element.data('params');
        } else {
          method = element.data('method');
          url = rails.href(element);
          data = element.data('params') || null;
        }

        options = {
          type: method || 'GET', data: data, dataType: dataType,
          // stopping the "ajax:beforeSend" event will cancel the ajax request
          beforeSend: function(xhr, settings) {
            if (settings.dataType === undefined) {
              xhr.setRequestHeader('accept', '*/*;q=0.5, ' + settings.accepts.script);
            }
            return rails.fire(element, 'ajax:beforeSend', [xhr, settings]);
          },
          success: function(data, status, xhr) {
            element.trigger('ajax:success', [data, status, xhr]);
          },
          complete: function(xhr, status) {
            element.trigger('ajax:complete', [xhr, status]);
          },
          error: function(xhr, status, error) {
            element.trigger('ajax:error', [xhr, status, error]);
          },
          xhrFields: {
            withCredentials: withCredentials
          },
          crossDomain: crossDomain
        };
        // Only pass url to `ajax` options if not blank
        if (url) { options.url = url; }

        var jqxhr = rails.ajax(options);
        element.trigger('ajax:send', jqxhr);
        return jqxhr;
      } else {
        return false;
      }
    },

    // Handles "data-method" on links such as:
    // <a href="/users/5" data-method="delete" rel="nofollow" data-confirm="Are you sure?">Delete</a>
    handleMethod: function(link) {
      var href = rails.href(link),
        method = link.data('method'),
        target = link.attr('target'),
        csrf_token = $('meta[name=csrf-token]').attr('content'),
        csrf_param = $('meta[name=csrf-param]').attr('content'),
        form = $('<form method="post" action="' + href + '"></form>'),
        metadata_input = '<input name="_method" value="' + method + '" type="hidden" />';

      if (csrf_param !== undefined && csrf_token !== undefined) {
        metadata_input += '<input name="' + csrf_param + '" value="' + csrf_token + '" type="hidden" />';
      }

      if (target) { form.attr('target', target); }

      form.hide().append(metadata_input).appendTo('body');
      form.submit();
    },

    /* Disables form elements:
      - Caches element value in 'ujs:enable-with' data store
      - Replaces element text with value of 'data-disable-with' attribute
      - Sets disabled property to true
    */
    disableFormElements: function(form) {
      form.find(rails.disableSelector).each(function() {
        var element = $(this), method = element.is('button') ? 'html' : 'val';
        element.data('ujs:enable-with', element[method]());
        element[method](element.data('disable-with'));
        element.prop('disabled', true);
      });
    },

    /* Re-enables disabled form elements:
      - Replaces element text with cached value from 'ujs:enable-with' data store (created in `disableFormElements`)
      - Sets disabled property to false
    */
    enableFormElements: function(form) {
      form.find(rails.enableSelector).each(function() {
        var element = $(this), method = element.is('button') ? 'html' : 'val';
        if (element.data('ujs:enable-with')) element[method](element.data('ujs:enable-with'));
        element.prop('disabled', false);
      });
    },

   /* For 'data-confirm' attribute:
      - Fires `confirm` event
      - Shows the confirmation dialog
      - Fires the `confirm:complete` event

      Returns `true` if no function stops the chain and user chose yes; `false` otherwise.
      Attaching a handler to the element's `confirm` event that returns a `falsy` value cancels the confirmation dialog.
      Attaching a handler to the element's `confirm:complete` event that returns a `falsy` value makes this function
      return false. The `confirm:complete` event is fired whether or not the user answered true or false to the dialog.
   */
    allowAction: function(element) {
      var message = element.data('confirm'),
          answer = false, callback;
      if (!message) { return true; }

      if (rails.fire(element, 'confirm')) {
        answer = rails.confirm(message);
        callback = rails.fire(element, 'confirm:complete', [answer]);
      }
      return answer && callback;
    },

    // Helper function which checks for blank inputs in a form that match the specified CSS selector
    blankInputs: function(form, specifiedSelector, nonBlank) {
      var inputs = $(), input, valueToCheck,
        selector = specifiedSelector || 'input,textarea';
      form.find(selector).each(function() {
        input = $(this);
        valueToCheck = input.is(':checkbox,:radio') ? input.is(':checked') : input.val();
        // If nonBlank and valueToCheck are both truthy, or nonBlank and valueToCheck are both falsey
        if (!!valueToCheck == !!nonBlank) {
          inputs = inputs.add(input);
        }
      });
      return inputs.length ? inputs : false;
    },

    // Helper function which checks for non-blank inputs in a form that match the specified CSS selector
    nonBlankInputs: function(form, specifiedSelector) {
      return rails.blankInputs(form, specifiedSelector, true); // true specifies nonBlank
    },

    // Helper function, needed to provide consistent behavior in IE
    stopEverything: function(e) {
      $(e.target).trigger('ujs:everythingStopped');
      e.stopImmediatePropagation();
      return false;
    },

    // find all the submit events directly bound to the form and
    // manually invoke them. If anyone returns false then stop the loop
    callFormSubmitBindings: function(form, event) {
      var events = form.data('events'), continuePropagation = true;
      if (events !== undefined && events['submit'] !== undefined) {
        $.each(events['submit'], function(i, obj){
          if (typeof obj.handler === 'function') return continuePropagation = obj.handler(event);
        });
      }
      return continuePropagation;
    },

    //  replace element's html with the 'data-disable-with' after storing original html
    //  and prevent clicking on it
    disableElement: function(element) {
      element.data('ujs:enable-with', element.html()); // store enabled state
      element.html(element.data('disable-with')); // set to disabled state
      $(document).on('click.railsDisable', element, function(e) { // prevent further clicking
        return rails.stopEverything(e);
      });
    },

    // restore element to its original state which was disabled by 'disableElement' above
    enableElement: function(element) {
      if (element.data('ujs:enable-with') !== undefined) {
        element.html(element.data('ujs:enable-with')); // set to old enabled state
        // this should be element.removeData('ujs:enable-with')
        // but, there is currently a bug in jquery which makes hyphenated data attributes not get removed
        element.data('ujs:enable-with', false); // clean up cache
      }
      element.unbind('click.railsDisable'); // enable element
    }

  };

  if (rails.fire($(document), 'rails:attachBindings')) {

    $.ajaxPrefilter(function(options, originalOptions, xhr){ if ( !options.crossDomain ) { rails.CSRFProtection(xhr); }});

    $(document).on('ajax:complete', rails.linkDisableSelector, function() {
        rails.enableElement($(this));
    });

    $(document).on('click.rails', rails.linkClickSelector, function(e) {
      var link = $(this), method = link.data('method'), data = link.data('params');
      if (!rails.allowAction(link)) return rails.stopEverything(e);

      if (link.is(rails.linkDisableSelector)) rails.disableElement(link);

      if (link.data('remote') !== undefined) {
        if ( (e.metaKey || e.ctrlKey) && (!method || method === 'GET') && !data ) { return true; }

        var handleRemote = rails.handleRemote(link);
        // response from rails.handleRemote() will either be false or a deferred object promise.
        if (handleRemote === false) {
          rails.enableElement(link);
        } else {
          handleRemote.fail( function() { rails.enableElement(link); } );
        }
        return false;

      } else if (link.data('method')) {
        rails.handleMethod(link);
        return false;
      }
    });

    $(document).on('change.rails', rails.inputChangeSelector, function(e) {
      var link = $(this);
      if (!rails.allowAction(link)) return rails.stopEverything(e);

      rails.handleRemote(link);
      return false;
    });

    $(document).on('submit.rails', rails.formSubmitSelector, function(e) {
      var form = $(this),
        remote = form.data('remote') !== undefined,
        blankRequiredInputs = rails.blankInputs(form, rails.requiredInputSelector),
        nonBlankFileInputs = rails.nonBlankInputs(form, rails.fileInputSelector);

      if (!rails.allowAction(form)) return rails.stopEverything(e);

      // skip other logic when required values are missing or file upload is present
      if (blankRequiredInputs && form.attr("novalidate") == undefined && rails.fire(form, 'ajax:aborted:required', [blankRequiredInputs])) {
        return rails.stopEverything(e);
      }

      if (remote) {
        if (nonBlankFileInputs) {
          setTimeout(function(){ rails.disableFormElements(form); }, 13);
          return rails.fire(form, 'ajax:aborted:file', [nonBlankFileInputs]);
        }

        // If browser does not support submit bubbling, then this live-binding will be called before direct
        // bindings. Therefore, we should directly call any direct bindings before remotely submitting form.
        if (!$.support.submitBubbles && $().jquery < '1.7' && rails.callFormSubmitBindings(form, e) === false) return rails.stopEverything(e);

        rails.handleRemote(form);
        return false;

      } else {
        // slight timeout so that the submit button gets properly serialized
        setTimeout(function(){ rails.disableFormElements(form); }, 13);
      }
    });

    $(document).on('click.rails', rails.formInputClickSelector, function(event) {
      var button = $(this);

      if (!rails.allowAction(button)) return rails.stopEverything(event);

      // register the pressed submit button
      var name = button.attr('name'),
        data = name ? {name:name, value:button.val()} : null;

      button.closest('form').data('ujs:submit-button', data);
    });

    $(document).on('ajax:beforeSend.rails', rails.formSubmitSelector, function(event) {
      if (this == event.target) rails.disableFormElements($(this));
    });

    $(document).on('ajax:complete.rails', rails.formSubmitSelector, function(event) {
      if (this == event.target) rails.enableFormElements($(this));
    });

    $(function(){
      // making sure that all forms have actual up-to-date token(cached forms contain old one)
      csrf_token = $('meta[name=csrf-token]').attr('content');
      csrf_param = $('meta[name=csrf-param]').attr('content');
      $('form input[name="' + csrf_param + '"]').val(csrf_token);
    });
  }

})( jQuery );

(function($) {
  $.flash = function(message) { $.flash.notice(message); };

  var timeouts = [],
      display_notice = function (message, clazz, opts) {

    $.flash.current = message;

    html = '<div class="navbar navbar-fixed-top navbar-default alert alert-' + clazz + '" data-dismiss="alert">'
    html +=   '<div class="container">'
    html +=     '<button type="button" class="close" aria-hidden="true">×</button>'
    html +=      message
    html +=    '</div>'
    html +=  '</div>'
    html +='</div>'
    $("#flash-messages").html(html);


  };

  $.flash.notice = function(message, opts) { display_notice(message, 'info', opts); };
  $.flash.error = function(message, opts)  { display_notice(message, 'error', opts); };

  $.flash.hide = function() {
    $.flash.current = null;
  };
})(jQuery);
(function($) {
  $(document).ready(function() {
    var addAcceptHeader = function(xhr) {
      xhr.setRequestHeader("Accept", "text/javascript, text/html, application/xml, text/xml, */*");
    }

    function remote() {
      var form = $(this);
      var buttons = form.find("input[type=submit], button[type=submit]");

      $.ajax({
        type:       form.attr("method"),
        url:        form.attr("action"),
        data:       form.serializeArray(),
        beforeSend: addAcceptHeader,
        complete:   function() { buttons.removeAttr("disabled"); }
      });

      buttons.attr("disabled", "true");

      return false;
    };

    // Ajax forms
    $("form.remote").on("submit", remote);

    // Ajax links
    $("a.remote").on("click", function() {
      $.ajax({url: this.href, beforeSend: addAcceptHeader});
      return false;
    });

    // Ajax forms if rails.js is not loaded.
    if ($.rails === void 0) {
      $("form[data-remote]").on("submit", remote);
    }
  });
})(jQuery);
(function($) {
  // ever heard about a toggle() function of jQuery?
  $.fn.enableSwitch = function() {
    var context = this;

    context.find(".disabled_block").fadeOut(function() {
      context.find(".enabled_block").fadeIn();
    })
  }

  $.fn.disableSwitch = function() {
    var context = this;

    context.find(".enabled_block").fadeOut(function() {
      context.find(".disabled_block").fadeIn();
    })
  }
})(jQuery);

(function($) {
  $(document).ready(function() {
    $("form.autosubmit").on("change", function() {
      if(typeof($.rails) != "undefined") {
        $.rails.handleRemote($(this));
      }
    });
  });
})(jQuery);
function visibility_condition_for(target_name, decider_name, value) {
  var target  = $('#' + target_name);
  var decider = $('#' + decider_name + '_input');

  decider.on('change', function(e) {
    if ($(this).val() == value) {
      target.show();
    } else {
      target.hide()
    }
  });

  decider.trigger('change');
}


;
(function ($) {

  // rest
  $(document).ready(function() {

    // disable links with 'data-disabled' attribute and display alert instead
    // delegation on body fires before rails.js
    $('body').on('click', 'a[data-disabled]', function(event) {
      event.preventDefault();
      event.stopImmediatePropagation();
      alert($(this).data('disabled'));
      return false;
    });

    (function(){
       // return if not in correct pages
      if($("#fields_definition_name").length == 0 ) return;
       // define functions
	 function disableInterface(){
	   function enable_checkboxes(){
	     checkboxes_disabled(false);
	   }

	   function disable_checkboxes(){
	     checkboxes_disabled(true);
	   }
	   function checkboxes_disabled(action){
	     $("#fields_definition_hidden").attr('disabled',action);
	     $("#fields_definition_read_only").attr('disabled',action);
	     $("#fields_definition_required").attr('disabled',action);
	   }
	   function disable_name_field(){
	     $("#fields_definition_name")[0].value = $("#fields_definition_fieldname")[0].value;
	     $("#fields_definition_name").attr('readonly', true);
	   }
	   function clear_checkboxes(){
	     $("#fields_definition_hidden")[0].checked=false;
	     $("#fields_definition_read_only")[0].checked=false;
	     $("#fields_definition_required")[0].checked=false;
	   }

	   function clear_choices(){
	     $("#fields_definition_choices_for_views")[0].value = '';
	   }
	   function read_only_choices(action){
	     $("#fields_definition_choices_for_views").attr('readonly', action);
	   }
	   function enable_choices(){
	     read_only_choices(false);
	   }
	   function disable_choices(){
	     read_only_choices(true);
	   }

	   // new view
	   if($("#fields_definition_fieldname").length != 0){
	     $("#fields_definition_fieldname").on('change', function() {
	       if($("#fields_definition_fieldname")[0].value == "[new field]"){
	         $("#fields_definition_name").attr('readonly', false);
	         $("#fields_definition_name")[0].value='';
	         clear_checkboxes();
	         enable_checkboxes();
	         clear_choices();
	         enable_choices();
	       }
	       else if($.inArray($("#fields_definition_fieldname")[0].value,
	      		$("#required_fields")[0].value.split(",")) != -1){
	       //non_modifiable fields
	         disable_name_field();
	         clear_checkboxes();
	         disable_checkboxes();
	         clear_choices();
		 enable_choices();
	       }
	       else {
	         disable_name_field();
	         clear_checkboxes();
	         enable_checkboxes();
	         clear_choices();
	         enable_choices();
	       }
	     });
	   }

           if (($("#fields_definition_required").length != 0 ) &&
	       ($("#fields_definition_required")[0].checked)){
             $("#fields_definition_hidden")[0].checked=false;
             $("#fields_definition_read_only")[0].checked=false;
             $("#fields_definition_hidden").attr('disabled',true);
             $("#fields_definition_read_only").attr('disabled',true);
           }

	     //edit view
           if($("#fields-definitions-edit-view").length != 0 ){
	     $("#fields_definition_name").attr('readonly', true);
	     $("#fields_definition_name").attr('disabled', true);
}	 };

	 disableInterface();
	 // disableCheckboxesOnload();
     })();

    (function(){
       // return if not in correct pages
       if($("#fields_definition_required").lenght==0) return;
       // define functions
       function synchronize_checkboxes(){
	 $("#fields_definition_required").on('change', function(){
	 if ($("#fields_definition_required")[0].checked){
	   $("#fields_definition_hidden")[0].checked=false;
	   $("#fields_definition_read_only")[0].checked=false;
	   $("#fields_definition_hidden").attr('disabled',true);
	   $("#fields_definition_read_only").attr('disabled',true);
	 }
	 else{
	   $("#fields_definition_hidden").attr('disabled',false);
	   $("#fields_definition_read_only").attr('disabled',false);
	 }});
       };
       // call function
       synchronize_checkboxes();
     })();

    (function(){
      if ($('#plan-select').length == 0) return;
	var currentPlanID = $('#plans-selector').attr('data-plan-id');
	var $plans = $('div.plan-preview');

	$('#plan-select')[0].options[0].value
	var options = $('#plan-select')[0].options;

	for (var i = options.length - 1; i >= 0; i--){
	  if(options[i].value == currentPlanID) {
	    options.selectedIndex = (i - length);
	  }
	};

      function attachEvents(){
	$('#plan-select').on('change', function(){

	  var planID = this.options[this.selectedIndex].value;
	    $plans.hide();
	    $('div.plan-preview[data-plan-id="'+planID+'"]').show();

	    // HACK HACK HACK - redo the plan selector!
	    if ($('#plans-selector').attr('data-plan-id') == planID) {
	      $('#plan-change-submit').hide();
	    } else {
	      $('#plan-change-submit').show();
	    }

	    return false;
	});
      }

      attachEvents();
    })();

    // Response of this form will be presented inside a colorbox.
    $("form.colorbox[data-remote]").on("submit", function(e) {
      $(this).on('ajax:complete', function(event, xhr, status){
        var form = $(this).closest('form');
        var width = form.data('width');
        $.colorbox({ open:true, html: xhr.responseText, width: width });
      })
    });

    $("a.fancybox, a.colorbox").on("click", function(e) {
      $(this).colorbox({ open:true });
      e.preventDefault();
    });

    $(".fancybox-close").on("click", function() {
      $.fancybox.close();
      return false;
    });

    // Show panel on click.
    $("a.show-panel").on('click', function() {
      findPanel($(this)).fadeIn("fast");
      return false;
    })

    // Hide panel on click.
    $("a.hide-panel").on('click', function() {
      findPanel($(this)).fadeOut("fast");
      return false;
    })

    // Toggle panel on click.
    $("a.toggle-panel").on('click', function() {
      var panel = findPanel($(this));

      if (panel.is(":visible")) {
	panel.fadeOut("fast");
      } else {
	panel.fadeIn("fast");
      }

      return false;
    });

    var findPanel = function(link) {
      var id = link.attr("data-panel");

      if (id) {
	return $("#" + id);
      } else {
	return $(link.attr("href"));
      }
    }

    // React to topics sort dropdown

    $('#forum select#s').on('change', function(){
      var param = this.options[this.selectedIndex].value || '',
	  view = $('div.by-category').attr('data-view'),
	  category = $('div.by-category').attr('data-category');

      location.href = "?view=" + view + "&s=" + param + "&for_category=" + category;
    });

    // show errors from ajax in formtastic
    $('form').on('ajax:error', function(event, xhr, status, error) {
      switch(status){
        case 'error':
          console.log(xhr.responseText)
          break;
      }
    });

    // Enable Tipsy for links with title to show nice and fast tooltips with title
    if($.fn.tipsy) {
      // can't enable live, because mouseleave is not called
      $('[title]').tipsy({gravity: $.fn.tipsy.autoWE});
      $('time').tipsy({gravity: $.fn.tipsy.autoWE})
    }

    $('#search_deleted_accounts').on('change', function(){
      $(this.form).submit();
    });
  });
})(jQuery);
