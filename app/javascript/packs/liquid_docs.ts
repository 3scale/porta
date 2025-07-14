import hljs from 'highlight.js/lib/core'
import django from 'highlight.js/lib/languages/django.js'
import xml from 'highlight.js/lib/languages/xml.js'
import 'highlight.js/styles/github.css'

hljs.registerLanguage('django', django)
hljs.registerLanguage('xml', xml)
hljs.configure({
  languages: ['django', 'xml'],
  cssSelector: '#liquid-docs pre code'
})

document.addEventListener('DOMContentLoaded', () => {
  hljs.highlightAll()
})
