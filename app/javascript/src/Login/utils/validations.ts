import validate from 'validate.js'

const loginConstraints = {
  username: { presence: { allowEmpty: false, message: 'Email or username is mandatory' } },
  password: { presence: { allowEmpty: false, message: 'Password is mandatory' } }
} as const

function validateLogin (fields: Record<keyof typeof loginConstraints, string>): Record<keyof typeof loginConstraints, string[] | undefined> | undefined {
  return validate(fields, loginConstraints, { fullMessages: false }) as Record<keyof typeof loginConstraints, string[] | undefined> | undefined
}

const changePasswordConstraints = {
  password: {
    presence: { allowEmpty: false, message: 'Password is mandatory' }
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
    presence: { allowEmpty: false, message: 'Username is mandatory' }
  },
  email: {
    email: { message: 'A valid email address is mandatory' }
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
