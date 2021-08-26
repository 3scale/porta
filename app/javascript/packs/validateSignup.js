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
    }
  }
  // $FlowFixMe[incompatible-type] should be safe to assume it is HTMLInputElement
  const submitBtn: HTMLInputElement = document.querySelector('input[type="submit"]')
  submitBtn.disabled = true

  const inputs = document.querySelectorAll('input')
  inputs.forEach(input => input.addEventListener('keyup', (event: KeyboardEvent) => {
    window.ThreeScaleSignUPData.validateForm()
  }))

  window.ThreeScaleSignUPData = {
    captchaValidOrAbsent: !document.querySelector('.g-recaptcha '),
    isFormValid: false,
    validateForm: function () {
      const form = document.querySelector('#signup_form')
      const errors = this.validate(form, this.constraints)
      this.isFormValid = !errors
      const formValid = this.isFormValid && this.captchaValidOrAbsent
      submitBtn.disabled = !formValid
    },
    validate,
    constraints
  }
})
