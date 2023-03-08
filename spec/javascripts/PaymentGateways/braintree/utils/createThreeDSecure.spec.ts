import { threeDSecure } from 'braintree-web'

import { createThreeDSecure } from 'PaymentGateways/braintree/utils/createThreeDSecure'

it('should create an instance of Braintree hosted fields', async () => {
  const create = jest.spyOn(threeDSecure, 'create')

  await createThreeDSecure('token')

  expect(create).toHaveBeenCalledWith({ authorization: 'token', version: 2 })
})
