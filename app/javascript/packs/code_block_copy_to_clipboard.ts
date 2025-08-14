/* eslint-disable @typescript-eslint/no-non-null-assertion */
document.addEventListener('DOMContentLoaded', () => {
  const buttons = document.querySelectorAll('.pf-c-button[aria-label="Copy to clipboard"]')
  buttons.forEach(button => {
    button.addEventListener('click', () => {
      const codeBlock = button.closest<HTMLElement>('.pf-c-code-block')!
      const code = codeBlock.querySelector<HTMLElement>('.pf-c-code-block__code')!.innerText
      const icon = codeBlock.querySelector<HTMLElement>('.fas.fa-copy')

      if (!icon) {
        return
      }

      navigator.clipboard.writeText(code)
        .then(() => {
          icon.classList.replace('fa-copy', 'fa-clipboard-check')

          setTimeout(() => {
            icon.classList.replace('fa-clipboard-check', 'fa-copy')
          }, 1000)
        })
        .catch(console.error)
    })
  })
})
