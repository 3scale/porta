type ValidatorFunc = () => 'default' | 'success' | 'error'

const Validator = () => {
  const validations: Record<string, ValidatorFunc> = {}

  const validate = (inputName: string) => {
    if (!Object.prototype.hasOwnProperty.call(validations, inputName)) {
      return 'default'
    }
    return validations[inputName]()
  }

  const addNewValidation = (inputName: string, func: ValidatorFunc) => {
    validations[inputName] = func
    // eslint-disable-next-line @typescript-eslint/no-use-before-define
    return self
  }

  const self = {
    validate,
    for: addNewValidation
  }

  return self
}

export { Validator }
