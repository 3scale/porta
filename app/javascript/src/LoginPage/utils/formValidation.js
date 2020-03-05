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

type HTMLForm = HTMLFormElement | {} | null

const validateForm = (form: HTMLForm, constraints: {}) => {
  return validate(form, constraints)
}

const validateSingleField = (event: SyntheticEvent<HTMLInputElement>) => {
  const {value, type} = event.currentTarget
  const fieldError = validate.single(value, constraintsTypes[type])
  return !fieldError
}

export {
  validateForm,
  validateSingleField
}
