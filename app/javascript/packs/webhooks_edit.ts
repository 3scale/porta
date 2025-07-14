import { toast } from 'utilities/toast'
import { ajaxJSON } from 'utilities/ajax'

import type { IAlert } from 'Types'

document.addEventListener('DOMContentLoaded', () => {
  const pingButton = document.querySelector<HTMLButtonElement>('button[data-ping-url]')

  if (!pingButton) {
    return
  }

  const { pingUrl } = pingButton.dataset as { pingUrl: string }
  const original = pingButton.textContent

  const enableButton = () => {
    pingButton.disabled = false
    pingButton.textContent = original
  }

  const disableButton = () => {
    pingButton.disabled = true
    pingButton.textContent = 'Pinging...'
  }

  pingButton.addEventListener('click', (event) => {
    event.preventDefault()
    event.stopImmediatePropagation()
    disableButton()

    ajaxJSON<Required<IAlert>>(pingUrl, { method: 'GET' })
      .then(res => res.json())
      .then(({ message, type }) => { toast(message, type) })
      .catch(console.error)
      .finally(enableButton)
  })
})
