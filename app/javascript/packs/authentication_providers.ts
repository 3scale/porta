// Small snippet to handle opening/closing of overflow menu, since this page is pure HTML.
document.addEventListener('DOMContentLoaded', () => {
  document.addEventListener('mouseup', () => {
    document.querySelectorAll<HTMLUListElement>('.pf-c-overflow-menu ul.pf-c-dropdown__menu')
      .forEach(menu => {
        menu.hidden = true
      })
  })

  document.querySelectorAll<HTMLButtonElement>('.pf-c-overflow-menu button.pf-c-dropdown__toggle')
    .forEach(toggle => {
      toggle.addEventListener('click', () => {
        // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
        const menu = toggle.nextElementSibling! as HTMLUListElement
        menu.hidden = !menu.hidden
      })
    })
})
