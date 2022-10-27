// TODO: remove or refactor this. It is not used.
import validate from 'validate.js'

import type { FormEvent } from 'react'

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

const validateForm = (form: unknown, constraints: unknown): Record<string, string[]> | undefined => {
  return validate(form, constraints) as Record<string, string[]>
}

const validateSingleField = (event: FormEvent<HTMLInputElement>): boolean => {
  const { value, type } = event.currentTarget
  const fieldError = validate.single(value, constraintsTypes[type as keyof typeof constraintsTypes]) as (string[] | undefined)
  return !fieldError
}

export {
  validateForm,
  validateSingleField
}
