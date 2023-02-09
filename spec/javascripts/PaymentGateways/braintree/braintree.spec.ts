import { hostedFields } from 'braintree-web'

import * as braintree from 'PaymentGateways/braintree/braintree'

describe('#createHostedFieldsInstance', () => {
  it('should create an instance of Braintree hosted fields', async () => {
    const create = jest.spyOn(hostedFields, 'create')

    await braintree.createHostedFieldsInstance('token')

    expect(create).toHaveBeenCalledWith({ authorization: 'token', fields: expect.any(Object), styles: expect.any(Object) })
  })
})
