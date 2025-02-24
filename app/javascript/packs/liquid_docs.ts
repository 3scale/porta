import hljs from 'highlight.js'

hljs.configure({ classPrefix: '' })

document.addEventListener('DOMContentLoaded', () => {
  document.querySelectorAll<HTMLElement>('#liquid-docs pre code')
    .forEach((el) => {
      hljs.highlightBlock(el)
    })
})
