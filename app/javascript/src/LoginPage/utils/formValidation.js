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
    length: {minimum: 1}
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

const namesToStateKeys = {
  'username': {
    'name': 'username',
    'isValid': 'isValidUsername'
  },
  'password': {
    'name': 'password',
    'isValid': 'isValidPassword'
  },
  'email': {
    'name': 'email',
    'isValid': 'isValidEmail'
  },
  'user[username]': {
    'name': 'username',
    'isValid': 'isValidUsername'
  },
  'user[email]': {
    'name': 'emailAddress',
    'isValid': 'isValidEmailAddress'
  },
  'user[first_name]': {
    'name': 'firstname',
    'isValid': 'isValidFirstname'
  },
  'user[last_name]': {
    'name': 'lastname',
    'isValid': 'isValidLastname'
  },
  'user[password]': {
    'name': 'password',
    'isValid': 'isValidPassword'
  },
  'user[password_confirmation]': {
    'name': 'passwordConfirmation',
    'isValid': 'isValidPasswordConfirmation'
  }
}

const validateAllFields = (form) => {
  const errors = validate(form, constraints[form.id])
  return errors ? Array.from(Object.keys(errors)) : undefined
}

const validateSingleField = (event) => {
  const type = event.currentTarget.type
  const fieldError = validate.single(event.currentTarget.value, constraintsTypes[type])
  return !fieldError
}

export {
  validateAllFields,
  namesToStateKeys,
  validateSingleField
}
