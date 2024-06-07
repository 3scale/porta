/* eslint-disable @typescript-eslint/no-non-null-assertion */
import Cookies from 'js-cookie'

document.addEventListener('DOMContentLoaded', () => {
  const drawer = document.querySelector<HTMLDivElement>('.pf-c-drawer')
  const toolbar = document.querySelector<HTMLDivElement>('#cms-toolbar')
  const iframe = document.querySelector<HTMLIFrameElement>('#developer-portal')

  if (!drawer || !toolbar || !iframe) {
    throw new Error('CMS toolbar with iframe not found!!')
  }

  const COOKIE_NAME = 'cms-toolbar-state'

  document.querySelector<HTMLLinkElement>('.pf-c-nav__list a.pf-m-current')!
    .addEventListener('click', (event) => { event.preventDefault() })

  document.querySelector<HTMLButtonElement>('#cms-toolbar-toggle')
    ?.addEventListener('click', () => {
      drawer.classList.toggle('pf-m-expanded')

      const currentState = (Cookies.get(COOKIE_NAME) ?? 'visible') as 'hidden' | 'visible'
      if (currentState === 'hidden') {
        Cookies.set(COOKIE_NAME, 'visible', { expires: 30 })
      } else {
        Cookies.set(COOKIE_NAME, 'hidden', { expires: 30 })
      }
    })

  const themePicker = document.querySelector<HTMLSelectElement>('#theme-picker')

  if (themePicker) {
    let style: Element | undefined = undefined

    const code = document.querySelector<HTMLElement>('#theme-snippet code')!
    const codeWrapper = document.querySelector<HTMLDivElement>('#theme-snippet')!

    themePicker.addEventListener('change', () => {
      const option = themePicker.querySelector<HTMLOptionElement>('option:checked')!
      const { snippet } = option.dataset as { snippet?: string }
      style?.remove()

      if (snippet) {
        style = document.createElement('style')
        style.innerHTML = snippet
        frames[0].document.querySelector('body')?.appendChild(style)

        codeWrapper.style.removeProperty('display')
        code.innerText = `<style>\n${snippet}</style>`
      } else {
        codeWrapper.style.display = 'none'
        code.innerText = ''
      }
    })
  }
})
