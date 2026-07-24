import { createElement } from 'react'
import { render } from 'react-dom'

import { AdminDomainConfirmation } from 'AdminDomainConfirmation/AdminDomainConfirmation'

document.addEventListener('DOMContentLoaded', () => {
  const containerId = 'admin-domain-confirmation-container'
  const container = document.getElementById(containerId)

  if (!container) return

  const form = document.querySelector<HTMLFormElement>('form.pf-c-form')
  const domainInput = document.querySelector<HTMLInputElement>('#account_self_domain')

  if (!form || !domainInput) return

  const initialDomain = domainInput.value

  const mountModal = (isOpen: boolean) => {
    render(
      createElement(AdminDomainConfirmation, {
        isOpen,
        onCancel: () => { mountModal(false) },
        onConfirm: () => {
          mountModal(false)
          form.submit()
        }
      }),
      container
    )
  }

  mountModal(false)

  form.addEventListener('submit', (e) => {
    if (domainInput.value !== initialDomain) {
      e.preventDefault()
      mountModal(true)
    }
  })
})
