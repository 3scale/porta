import { hostedFields } from 'braintree-web'

import { createHostedFields } from 'PaymentGateways/braintree/utils/createHostedFields'

it('should create an instance of Braintree hosted fields', async () => {
  const create = jest.spyOn(hostedFields, 'create')

  await createHostedFields('token')

  expect(create).toHaveBeenCalledWith({ authorization: 'token', fields: expect.any(Object), styles: expect.any(Object) })
})
