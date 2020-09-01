document.addEventListener('DOMContentLoaded', () => {
  const select = document.querySelector('table .pf-c-select')
  const ul = document.querySelector('ul.pf-c-select__menu')

  select.addEventListener('click', () => {
    select.classList.toggle('pf-m-expanded')
    ul.toggleAttribute('hidden')
  })
})
