/* eslint-disable @typescript-eslint/no-non-null-assertion -- Safe to assume everything is there */

document.addEventListener('DOMContentLoaded', () => {
  const docs = document.querySelector<HTMLAnchorElement>('.PopNavigation--docs a')!
  const docsMenu = document.querySelector<HTMLUListElement>('.PopNavigation--docs ul')!
  const session = document.querySelector<HTMLAnchorElement>('.PopNavigation--session a')!
  const sessionMenu = document.querySelector<HTMLUListElement>('.PopNavigation--session ul')!

  const expandedClass = 'is-expanded'

  docs.addEventListener('click', (e: Event) => {
    e.stopPropagation()
    e.preventDefault()

    docs.classList.add(expandedClass)
    docsMenu.classList.add(expandedClass)

    session.classList.remove(expandedClass)
    sessionMenu.classList.remove(expandedClass)
  })

  session.addEventListener('click', (e: Event) => {
    e.stopPropagation()
    e.preventDefault()

    session.classList.add(expandedClass)
    sessionMenu.classList.add(expandedClass)

    docs.classList.remove(expandedClass)
    docsMenu.classList.remove(expandedClass)
  })

  document.body.addEventListener('click', () => {
    [docs, docsMenu, session, sessionMenu].forEach(({ classList }) => {
      classList.remove(expandedClass)
    })
  })
})
