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
    length: {minimum: 1}
  }
}

const validateSingleField = (event: SyntheticEvent<HTMLInputElement>) => {
  const {value, type} = event.currentTarget
  const fieldError = validate.single(value, constraintsTypes[type])
  return !fieldError
}

export {
  validateSingleField
}
