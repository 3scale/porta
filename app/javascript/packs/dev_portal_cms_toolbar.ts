/* eslint-disable @typescript-eslint/no-non-null-assertion */
import $ from 'jquery'
import Cookies from 'js-cookie'

document.addEventListener('DOMContentLoaded', () => {
  const toolbar = document.querySelector<HTMLDivElement>('#cms-toolbar')
  const iframe = document.querySelector<HTMLIFrameElement>('#developer-portal')

  const toolbarState = Cookies.get('cms-toolbar-state') ?? 'visible' as 'hidden' | 'visible'

  if (!toolbar || !iframe) {
    return
  }

  document.querySelector<HTMLLinkElement>('#cms-toolbar-menu-middle li.active a')!
    .addEventListener('click', (event) => { event.preventDefault() })

  document.querySelector<HTMLHtmlElement>('#hide-side-bar')
    ?.addEventListener('click', () => {
      toggleValues()

      const newState = toolbarState === 'hidden' ? 'visible' : 'hidden'
      Cookies.set('cms-toolbar-state', newState, { expires: 30 })
    })

  $(iframe).on('load', () => {
    if (toolbarState !== 'hidden') {
      toggleValues()
      window.requestAnimationFrame(enableAnimation)
    } else {
      enableAnimation()
    }
  })

  const toggleValues = () => {
    toolbar.classList.toggle('not-hidden')
    iframe.classList.toggle('not-full')
  }

  const enableAnimation = () => {
    toolbar.classList.add('animate')
    iframe.classList.add('animate')
  }

  const themePicker = document.querySelector<HTMLSelectElement>('#theme-picker')

  if (themePicker) {
    let selectedTheme: JQuery | undefined = undefined

    themePicker.addEventListener('change', () => {
      const textareaWrapper = document.querySelector<HTMLDivElement>('#theme-snippet')!
      const textarea = document.querySelector<HTMLTextAreaElement>('#theme-snippet textarea')!

      const option = themePicker.querySelector<HTMLOptionElement>('option:checked')!
      const { snippet } = option.dataset

      if (snippet) {
        selectedTheme = $(`<style>${snippet}</style>`)
        $('body', frames[0].document).append(selectedTheme)

        const text = `<!-- Copy & paste this snippet into your template called main layout to make this change permanent -->\n\n<style>\n${snippet}</style>`
        textareaWrapper.style.removeProperty('display')
        textarea.value = text
      } else {
        selectedTheme?.remove()
        textareaWrapper.style.display = 'none'
        textarea.value = ''
      }
    })
  }
})
