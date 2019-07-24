import validate from 'validate.js'

const constraintsTypes = {
  text: {
    presence: true,
    length: {minimum: 1}
  },
  email: {
    presence: true,
    email: true,
    length: {minimum: 1}
  },
  password: {
    presence: true,
    length: {minimum: 6}
  },
  password_confirmation: {
    presence: true,
    length: {minimum: 1},
    equality: {
      attribute: 'user[password]'
    }
  }
}

const constraints = {
  'new_session': {
    'username': constraintsTypes.text,
    'password': constraintsTypes.password
  },
  'request_password': {
    'email': constraintsTypes.email
  },
  'signup_form': {
    'user[username]': constraintsTypes.text,
    'user[email]': constraintsTypes.email,
    'user[password]': constraintsTypes.password,
    'user[password_confirmation]': constraintsTypes.password_confirmation
  }
}

const validateAllFields = (form) => {
  const errors = validate(form, constraints[form.id])

  if (!errors) {
    return undefined
  } else {
    return Object.keys(errors).reduce((obj, item) => {
      obj[item] = false
      return obj
    }, {})
  }
}

const validateSingleField = (event) => {
  const type = event.currentTarget.type
  const fieldError = validate.single(event.currentTarget.value, constraintsTypes[type])
  return !fieldError
}

export {
  validateAllFields,
  validateSingleField
}
