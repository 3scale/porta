import validate from 'validate.js'

document.addEventListener('DOMContentLoaded', () => {
  const form = document.getElementById('signup_form') as HTMLFormElement
  // eslint-disable-next-line @typescript-eslint/non-nullable-type-assertion-style -- Need to cast to HTMLButtonElement
  const submitBtn = document.querySelector('input[type="submit"]') as HTMLButtonElement
  const captchaInput = document.getElementById('captchaChecked') as HTMLInputElement

  /* eslint-disable @typescript-eslint/naming-convention */
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
  const passwordFields = isPasswordRequired && {
    'account[user][password]': {
      presence: true,
      length: { minimum: 1 }
    },
    // eslint-disable-next-line @typescript-eslint/naming-convention
    'account[user][password_confirmation]': {
      presence: true,
      equality: 'account[user][password]'
    }
  }
  /* eslint-enable @typescript-eslint/naming-convention */

  const captchaRequired: boolean = document.querySelector('.g-recaptcha') !== null
  const captchaFields = captchaRequired && {
    'captchaChecked': {
      presence: true,
      length: { minimum: 1 }
    }
  }

  const constraints = Object.assign({}, mandatoryFields, passwordFields, captchaFields)

  submitBtn.disabled = validate(form, constraints) !== undefined
  captchaInput.value = captchaRequired ? '' : 'ok'

  const inputs = document.querySelectorAll('input')
  inputs.forEach(input => {
    input.addEventListener('keyup', () => {
      submitBtn.disabled = Boolean(validate(form, constraints))
    })
  })
})
