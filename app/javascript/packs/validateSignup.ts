import validate from 'validate.js'

document.addEventListener('DOMContentLoaded', () => {
  const form = document.getElementById('signup_form') as HTMLFormElement
  const submitBtn = document.querySelector('input[type="submit"]') as HTMLInputElement
  const captchaInput = document.getElementById('captchaChecked') as HTMLInputElement

  // Fields 'org_name', 'username' and 'email' are always required
  const mandatoryFields = {
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
    }
  } as const
  // Fields 'password' and 'password_confirmation' are optional (can be disabled)
  const isPasswordRequired = document.querySelectorAll('input[type="password"]').length > 0
  const passwordFields = isPasswordRequired ? {
    'account[user][password]': {
      presence: true,
      length: { minimum: 1 }
    },
    'account[user][password_confirmation]': {
      presence: true,
      equality: 'account[user][password]'
    }
  } : null

  const captchaRequired: boolean = document.querySelector('.g-recaptcha') !== null
  const captchaFields = captchaRequired ? {
    'captchaChecked': {
      presence: true,
      length: { minimum: 1 }
    }
  } : null

  const constraints = Object.assign({}, mandatoryFields, passwordFields, captchaFields)

  submitBtn.disabled = validate(form, constraints) !== undefined
  captchaInput.value = captchaRequired ? '' : 'ok'

  const inputs = document.querySelectorAll('input')
  inputs.forEach(input => input.addEventListener('keyup', () => {
    const errors = validate(form, constraints)
    submitBtn.disabled = !!errors
  }))
})
