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

type HTMLForm = HTMLFormElement | Record<any, any> | null;

const validateForm = (form: HTMLForm, constraints: Record<any, any>): undefined | {
  string: Array<string>
} => {
  return validate(form, constraints)
}

const validateSingleField = (event: React.SyntheticEvent<HTMLInputElement>): boolean => {
  const { value, type } = event.currentTarget
  const fieldError: undefined | Array<string> = validate.single(value, constraintsTypes[type as keyof typeof constraintsTypes])
  return !fieldError
}

export {
  validateForm,
  validateSingleField
}
