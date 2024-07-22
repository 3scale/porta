import * as flash from 'utilities/flash'
import { ajaxJSON } from 'utilities/ajax'

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

    ajaxJSON<{ error: string } | { notice: string }>(pingUrl, { method: 'GET' })
      .then(res => res.json())
      .then(({ notice, error }) => {
        if (notice) {
          flash.notice(notice)
        } else if (error) {
          flash.error(error)
        }
      })
      .catch(console.error)
      .finally(enableButton)
  })
})
