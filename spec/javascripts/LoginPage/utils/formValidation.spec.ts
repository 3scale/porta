import { validateSingleField } from 'LoginPage/utils/formValidation'

const fakeEvent = (type: string, value: string) => (
  { currentTarget: { value, type } } as unknown as React.SyntheticEvent<HTMLInputElement>
)

describe('#validateSingleField', () => {
  it('validates text', () => {
    expect(validateSingleField(fakeEvent('text', ''))).toEqual(false)
    expect(validateSingleField(fakeEvent('text', 'p'))).toEqual(true)
  })

  it('validates email', () => {
    expect(validateSingleField(fakeEvent('email', ''))).toEqual(false)
    expect(validateSingleField(fakeEvent('email', 'pepe'))).toEqual(false)
    expect(validateSingleField(fakeEvent('email', 'pepe@example.com'))).toEqual(true)
    expect(validateSingleField(fakeEvent('email', 'pe.p.e@exa-mple.com'))).toEqual(true)
  })

  it('validates password', () => {
    expect(validateSingleField(fakeEvent('password', ''))).toEqual(false)
    expect(validateSingleField(fakeEvent('password', 'p'))).toEqual(true)
  })
})
