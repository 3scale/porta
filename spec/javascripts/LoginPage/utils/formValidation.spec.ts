import { validateSingleField } from 'LoginPage/utils/formValidation'

const event = (type: string, value: string) => (
  { currentTarget: { value, type } } as unknown as React.SyntheticEvent<HTMLInputElement>
)

describe('#validateSingleField', () => {
  it('validates text', () => {
    expect(validateSingleField(event('text', ''))).toEqual(false)
    expect(validateSingleField(event('text', 'p'))).toEqual(true)
  })

  it('validates email', () => {
    expect(validateSingleField(event('email', ''))).toEqual(false)
    expect(validateSingleField(event('email', 'pepe'))).toEqual(false)
    expect(validateSingleField(event('email', 'pepe@example.com'))).toEqual(true)
    expect(validateSingleField(event('email', 'pe.p.e@exa-mple.com'))).toEqual(true)
  })

  it('validates password', () => {
    expect(validateSingleField(event('password', ''))).toEqual(false)
    expect(validateSingleField(event('password', 'p'))).toEqual(true)
  })
})
