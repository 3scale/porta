import { threeDSecure } from 'braintree-web'

import type { ThreeDSecure } from 'braintree-web'

const createThreeDSecure = (authorization: string): Promise<ThreeDSecure> => threeDSecure.create({ authorization, version: 2 })

export { createThreeDSecure }
