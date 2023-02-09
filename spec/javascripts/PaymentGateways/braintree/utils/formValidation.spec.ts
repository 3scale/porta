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
      address: ['Address is too short (minimum is 1 characters)'],
      city: ['City is too short (minimum is 1 characters)'],
      company: ['Company is too short (minimum is 1 characters)'],
      country: ['Country is too short (minimum is 1 characters)'],
      firstName: ['First name is too short (minimum is 1 characters)'],
      lastName: ['Last name is too short (minimum is 1 characters)'],
      phone: ['Phone is too short (minimum is 1 characters)'],
      zip: ['Zip is too short (minimum is 1 characters)']
    })
  })
})
