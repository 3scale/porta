import type { IAlertType } from 'Types'

const TIMEOUT = 8000

const typeIcons: Record<IAlertType, string> = {
  danger: 'exclamation-circle',
  info: 'info-circle',
  success: 'check-circle',
  warning: 'exclamation-triangle',
  default: 'bell'
}

function createAlertGroupItem (message: string, type: IAlertType = 'default'): HTMLLIElement {
  const li = document.createElement('li')
  li.className = 'pf-c-alert-group__item animate__animated animate__slideInRight animate__faster'

  const alertDiv = document.createElement('div')
  alertDiv.className = `pf-c-alert pf-m-${type}`
  alertDiv.setAttribute('aria-label', `${type} alert`)

  const iconDiv = document.createElement('div')
  iconDiv.className = 'pf-c-alert__icon'

  const icon = document.createElement('i')
  icon.className = `fas fa-fw fa-${typeIcons[type] || 'bell'}`
  icon.setAttribute('aria-hidden', 'true')

  const titleParagraph = document.createElement('p')
  titleParagraph.className = 'pf-c-alert__title'

  const screenReaderSpan = document.createElement('span')
  screenReaderSpan.className = 'pf-screen-reader'
  screenReaderSpan.textContent = `${type} alert: `

  const actionDiv = document.createElement('div')
  actionDiv.className = 'pf-c-alert__action'

  const closeButton = document.createElement('button')
  closeButton.className = 'pf-c-button pf-m-plain'
  closeButton.type = 'button'
  closeButton.title = 'Close alert'

  closeButton.onclick = () => { hideToast(li) }

  const closeIcon = document.createElement('i')
  closeIcon.className = 'fas fa-times'
  closeIcon.ariaHidden = 'true'

  const titleText = document.createTextNode(message)

  iconDiv.appendChild(icon)
  titleParagraph.appendChild(screenReaderSpan)
  titleParagraph.appendChild(titleText)
  closeButton.appendChild(closeIcon)
  actionDiv.appendChild(closeButton)
  alertDiv.appendChild(iconDiv)
  alertDiv.appendChild(titleParagraph)
  alertDiv.appendChild(actionDiv)
  li.appendChild(alertDiv)

  return li
}

export const toast = (message: string, type: IAlertType = 'default'): void => {
  const groupAlert = document.querySelector('.pf-c-alert-group.pf-m-toast')

  if (!groupAlert) {
    throw new Error('Tried to append a new toast alert, but alert group was not found')
  }

  const alert = createAlertGroupItem(message, type)

  groupAlert.appendChild(alert)
  hideToastDelayed(alert)
}

export const hideToastDelayed = (alertGroupItem: HTMLLIElement): void => {
  setTimeout(() => {
    hideToast(alertGroupItem)
  }, TIMEOUT)
}

export const hideToast = (alertGroupItem: HTMLLIElement): void => {
  alertGroupItem.classList.replace('animate__slideInRight', 'animate__fadeOut')
  alertGroupItem.onanimationend = () => {
    alertGroupItem.remove()
  }
}

/**
 * For alerts rendered by rails, set close buttons up and set timeouts to automacally hide.
 */
export const setUpToasts = (): void => {
  document.querySelectorAll<HTMLLIElement>('.pf-c-alert-group.pf-m-toast .pf-c-alert-group__item')
    .forEach(li => {
      hideToastDelayed(li)
      li.querySelector('button')?.addEventListener('click', () => { window.ThreeScale.hideToast(li) })
    })
}
