// @flow

import validate from 'validate.js'

document.addEventListener('DOMContentLoaded', () => {
  const constraints = {
    'account[org_name]': {
      presence: true,
      length: { minimum: 1 }
    },
    'account[user][username]': {
      presence: true,
      length: { minimum: 1 }
    },
    'account[user][email]': {
      presence: true,
      email: true,
      length: { minimum: 1 }
    },
    'account[user][password]': {
      presence: true,
      length: { minimum: 1 }
    },
    'account[user][password_confirmation]': {
      presence: true,
      equality: 'account[user][password]'
    },
    'captchaChecked': {
      presence: true,
      length: { minimum: 1 }
    }
  }

  // $FlowFixMe[incompatible-type] should be safe to assume it is HTMLFormElement
  const form: HTMLFormElement = document.querySelector('#signup_form')
  // $FlowFixMe[incompatible-type] should be safe to assume it is HTMLInputElement
  const submitBtn: HTMLInputElement = document.querySelector('input[type="submit"]')
  // $FlowFixMe[incompatible-type] should be safe to assume it is HTMLInputElement
  const captchaInput: HTMLInputElement = document.querySelector('#captchaChecked')

  const captchaRequired: boolean = !!document.querySelector('.g-recaptcha')
  submitBtn.disabled = true
  captchaInput.value = captchaRequired ? '' : 'ok'

  const inputs = document.querySelectorAll('input')
  inputs.forEach(input => input.addEventListener('keyup', (event: KeyboardEvent) => {
    const errors = validate(form, constraints)
    submitBtn.disabled = !!errors
  }))
})
