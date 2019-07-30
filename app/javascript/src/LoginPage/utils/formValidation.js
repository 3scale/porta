// @flow

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

// validate.js has a libdef, but it's missing 'formatters'
// See: https://github.com/flow-typed/flow-typed/blob/master/definitions/npm/validate.js_v0.x.x/flow_v0.25.x-/validate.js_v0.x.x.js
// $FlowFixMe
validate.formatters.customFormat = (errors) => {
  return errors.reduce((obj, item) => {
    obj[item.attribute] = false
    return obj
  }, {})
}

const validateAllFields = (form: HTMLFormElement) => validate(form, constraints[form.id], {format: 'customFormat'})

const validateSingleField = (event: SyntheticEvent<HTMLInputElement>) => {
  const type = event.currentTarget.type
  const fieldError = validate.single(event.currentTarget.value, constraintsTypes[type])
  return !fieldError
}

export {
  validateAllFields,
  validateSingleField
}
