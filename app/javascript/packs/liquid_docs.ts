import hljs from 'highlight.js'

document.addEventListener('DOMContentLoaded', () => {
  document.querySelectorAll<HTMLElement>('#liquid-docs pre code')
    .forEach((el) => {
      hljs.highlightBlock(el)
    })
})
