import * as formValidation from 'PaymentGateways/braintree/utils/formValidation'

describe('validateForm', () => {
  it('should validate all fields', () => {
    expect(formValidation.validateForm({
      address: 'address',
      city: 'city',
      company: 'company',
      country: 'country',
      firstName: 'firstName',
      lastName: 'lastName',
      phone: 'phone',
      state: '',
      zip: 'zip'
    })).toEqual(undefined)

    expect(formValidation.validateForm({
      address: '',
      city: '',
      company: '',
      country: '',
      firstName: '',
      lastName: '',
      phone: '',
      state: '',
      zip: ''
    })).toEqual({
      address: ['Address can\'t be blank'],
      city: ['City can\'t be blank'],
      company: ['Company can\'t be blank'],
      country: ['Country can\'t be blank'],
      firstName: ['First name can\'t be blank'],
      lastName: ['Last name can\'t be blank'],
      phone: ['Phone can\'t be blank'],
      zip: ['Zip can\'t be blank']
    })
  })

  it('should not validate countryCodeAlpha2', () => {
    expect(formValidation.validateForm({ countryCodeAlpha2: 'This is totally wrong' }))
      .not.toMatchObject({ countryCodeAlpha2: expect.anything() })
  })
})
