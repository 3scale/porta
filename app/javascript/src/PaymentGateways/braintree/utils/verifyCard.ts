import type { ThreeDSecureVerifyOptions } from 'braintree-web/modules/three-d-secure'
import type { ThreeDSecure, ThreeDSecureVerifyPayload } from 'braintree-web'

// HACK: here's a manual promise because ThreeDSecure.verifyCard throws a ts error when awaited. TODO: remove this in a future update.
const verifyCard = (threeDSecureInstance: ThreeDSecure, options: ThreeDSecureVerifyOptions): Promise<ThreeDSecureVerifyPayload> => {
  return new Promise((res, rej) => {
    threeDSecureInstance.verifyCard(options, (err, data) => {
      if (err) {
        rej(err)
      } else {
        // TODO: confirm nothing is to do here about liabilityShifted
        // eslint-disable-next-line @typescript-eslint/no-non-null-assertion -- Let's assume data exists as long as error doesn't
        res(data!)
      }
    })
  })
}

export { verifyCard }
