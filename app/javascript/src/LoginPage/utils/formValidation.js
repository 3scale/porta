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
  }
}

const isFormDisabled = (fields: Array<boolean>) => fields.some(value => value !== true)

const validateSingleField = (event: SyntheticEvent<HTMLInputElement>) => {
  const type = event.currentTarget.type
  const fieldError = validate.single(event.currentTarget.value, constraintsTypes[type])
  return !fieldError
}

export {
  validateSingleField,
  isFormDisabled
}
