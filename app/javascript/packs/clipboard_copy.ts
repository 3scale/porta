/* eslint-disable @typescript-eslint/no-non-null-assertion */
document.addEventListener('DOMContentLoaded', () => {
  const buttons = document.querySelectorAll('.pf-c-button[aria-label="Copy to clipboard"]')
  buttons.forEach(button => {
    button.addEventListener('click', () => {
      const container = button.closest<HTMLDivElement>('.pf-c-clipboard-copy')!
      const { value } = container.querySelector<HTMLInputElement>('.pf-c-clipboard-copy input')!
      const icon = container.querySelector<HTMLElement>('.fas.fa-copy')

      if (!icon) {
        return
      }

      navigator.clipboard.writeText(value)
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
