import validate from 'validate.js'

// IMPORTANT: This STRONG_PASSWORD_MIN_SIZE constant is duplicated from the backend.
// The source of truth is app/lib/authentication/by_password.rb. If this constant changes in Ruby,
// you must update it here as well. Do not modify it without updating the backend first.
const STRONG_PASSWORD_MIN_SIZE = 15

const loginConstraints = {
  username: { presence: { allowEmpty: false, message: 'Email or username is mandatory' } },
  password: { presence: { allowEmpty: false, message: 'Password is mandatory' } }
} as const

function validateLogin (fields: Record<keyof typeof loginConstraints, string>): Record<keyof typeof loginConstraints, string[] | undefined> | undefined {
  return validate(fields, loginConstraints, { fullMessages: false }) as Record<keyof typeof loginConstraints, string[] | undefined> | undefined
}

const changePasswordConstraints = {
  password: {
    presence: { allowEmpty: false, message: 'Password is mandatory' },
    length: { minimum: STRONG_PASSWORD_MIN_SIZE }
  },
  passwordConfirmation: {
    presence: { allowEmpty: false, message: 'Password confirmation is mandatory' },
    equality: { attribute: 'password', message: 'Password and Password confirmation must match' }
  }
} as const

function validateChangePassword (fields: Record<keyof typeof changePasswordConstraints, string>): Record<keyof typeof changePasswordConstraints, string[] | undefined> | undefined {
  return validate(fields, changePasswordConstraints, { fullMessages: false }) as Record<keyof typeof changePasswordConstraints, string[] | undefined> | undefined
}

const signupConstraints = {
  username: {
    presence: { allowEmpty: false, message: 'Username is mandatory' },
    length: { minimum: 3, maximum: 40 }
  },
  email: {
    email: { message: 'A valid email address is mandatory' },
    length: { minimum: 6, maximum: 255 }
  },
  firstName: {
    length: { maximum: 255 }
  },
  lastName: {
    length: { maximum: 255 }
  },
  ...changePasswordConstraints
} as const

function validateSignup (fields: Record<keyof typeof signupConstraints, string>): Record<keyof typeof signupConstraints, string[] | undefined> | undefined {
  return validate(fields, signupConstraints, { fullMessages: false }) as Record<keyof typeof signupConstraints, string[] | undefined> | undefined
}

const requestPasswordConstraints = signupConstraints.email

function validateRequestPassword (value: string): string[] | undefined {
  return validate.single(value, requestPasswordConstraints, { fullMessages: false }) as string[] | undefined
}

export {
  validateLogin,
  validateChangePassword,
  validateSignup,
  validateRequestPassword
}
