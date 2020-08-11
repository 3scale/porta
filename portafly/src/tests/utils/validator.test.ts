import { Validator } from 'utils'

const validInput = 'name'
const invalidInput = 'wrong'
const inexistentInput = 'nope'

const validator = Validator()
  .for(validInput, () => 'success')
  .for(invalidInput, () => 'error')

it('should return default when validation does not exist', () => {
  expect(validator.validate(inexistentInput)).toBe('default')
})

it('should validate', () => {
  expect(validator.validate(validInput)).toBe('success')
  expect(validator.validate(invalidInput)).toBe('error')
})
