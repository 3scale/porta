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
} as const

const validateForm = (form: unknown, constraints: unknown): Record<string, string[]> | undefined => {
  return validate(form, constraints) as Record<string, string[]>
}

const validateSingleField = (event: FormEvent<HTMLInputElement>): boolean => {
  const { value, type } = event.currentTarget as { value: string; type: keyof typeof constraintsTypes }
  // eslint-disable-next-line @typescript-eslint/no-unsafe-assignment -- TODO: check validate.single types, is it really any?
  const fieldError = validate.single(value, constraintsTypes[type])
  return !fieldError
}

export {
  validateForm,
  validateSingleField
}
