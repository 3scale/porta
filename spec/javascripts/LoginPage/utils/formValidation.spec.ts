import { validateSingleField } from 'Login/utils/formValidation'

const fakeEvent = (type: string, value: string) => (
  { currentTarget: { value, type } } as unknown as React.SyntheticEvent<HTMLInputElement>
)

describe('#validateSingleField', () => {
  it('validates text', () => {
    expect(validateSingleField(fakeEvent('text', '').currentTarget)).toEqual(false)
    expect(validateSingleField(fakeEvent('text', 'p').currentTarget)).toEqual(true)
  })

  it('validates email', () => {
    expect(validateSingleField(fakeEvent('email', '').currentTarget)).toEqual(false)
    expect(validateSingleField(fakeEvent('email', 'pepe').currentTarget)).toEqual(false)
    expect(validateSingleField(fakeEvent('email', 'pepe@example.com').currentTarget)).toEqual(true)
    expect(validateSingleField(fakeEvent('email', 'pe.p.e@exa-mple.com').currentTarget)).toEqual(true)
  })

  it('validates password', () => {
    expect(validateSingleField(fakeEvent('password', '').currentTarget)).toEqual(false)
    expect(validateSingleField(fakeEvent('password', 'p').currentTarget)).toEqual(true)
  })
})
