// @flow

import validate from 'validate.js'

const constraintsTypes = {
  text: {
    presence: true,
    length: { minimum: 1 }
  },
  email: {
    presence: true,
    email: true,
    length: { minimum: 1 }
  },
  password: {
    presence: true,
    length: { minimum: 1 }
  }
}

type HTMLForm = HTMLFormElement | {} | null

const validateForm = (form: HTMLForm, constraints: {}): void | { string: Array<string> } => {
  // $FlowIgnore[incompatible-return] we can safely assume types here
  return validate(form, constraints)
}

const validateSingleField = (event: SyntheticEvent<HTMLInputElement>): boolean => {
  const { value, type } = event.currentTarget
  // $FlowIgnore[incompatible-type] we can safely assume types here
  const fieldError: void | Array<string> = validate.single(value, constraintsTypes[type])
  return !fieldError
}

export {
  validateForm,
  validateSingleField
}
