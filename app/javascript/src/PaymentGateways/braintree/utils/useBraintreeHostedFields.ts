import { useEffect, useState } from 'react'

import { createHostedFields } from 'PaymentGateways/braintree/utils/createHostedFields'
import { createThreeDSecure } from 'PaymentGateways/braintree/utils/createThreeDSecure'
import { verifyCard } from 'PaymentGateways/braintree/utils/verifyCard'

import type { BraintreeError } from 'braintree-web'
import type { BillingAddress } from 'PaymentGateways/braintree/types'
import type { HostedFields, HostedFieldsFieldDataFields } from 'braintree-web/modules/hosted-fields'

type CustomHostedFields = HostedFields & {
  getNonce: (BillingAddress: BillingAddress) => Promise<string>;
}

/**
 * This custom hook handles HostedFields instantiation and usage asynchronously and painlessly.
 * It will try to create both a HostedFieldsInstance and a ThreeDSecureInstance but the latter will
 * only be used when `threeDSecureEnabled` is true. Otherwise, the nonce will be fetched from the
 * TokenizePayload without card verification.
 *
 * As long as there are background tasks running `loading` will be true.
 *
 * Once HostedFields is created, it is injected with a new function getNonce() that takes a billing
 * address in order to verify the card and eventually return a nonce value to be sent to the
 * server.
 *
 * @param clientToken The braintree authorization client token
 * @param threeDSecureEnabled Whether card is to be verified via 3DS v2
 *
 * @returns An array containing [hostedFields, error, loading, valid]
 */
const useBraintreeHostedFields = (
  clientToken: string,
  threeDSecureEnabled: boolean
): [CustomHostedFields | undefined, BraintreeError | undefined, boolean, boolean] => {
  const [loading, setLoading] = useState(true)
  const [hostedFields, setHostedFields] = useState<CustomHostedFields>()
  const [error, setError] = useState<BraintreeError>()
  const [valid, setValid] = useState(false)

  useEffect(() => {
    Promise.all([
      createHostedFields(clientToken),
      createThreeDSecure(clientToken)
    ]).then(([hostedFieldsInstance, threeDSecureInstance]) => {
      hostedFieldsInstance.on('validityChange', () => {
        const { fields } = hostedFieldsInstance.getState()

        setValid(Object.keys(fields).every((key) => fields[key as keyof HostedFieldsFieldDataFields].isValid))
      })

      threeDSecureInstance.on('lookup-complete', (_data, next) => {
        // eslint-disable-next-line @typescript-eslint/no-non-null-assertion -- Braintree doc assumes this exist, so we do the same.
        next!()
      })

      const customHostedFields = {
        ...hostedFieldsInstance,
        getNonce: async (billingAddress: BillingAddress): Promise<string> => {
          const payload = await hostedFieldsInstance.tokenize()

          if (!threeDSecureEnabled) {
            return payload.nonce
          }

          const { nonce } = await verifyCard(threeDSecureInstance, {
            nonce: payload.nonce,
            bin: payload.details.bin,
            // @ts-expect-error amount is a string accordint to docs: https://braintree.github.io/braintree-web/current/ThreeDSecure.html#~verifyPayload
            amount: '0.00',
            billingAddress: {
              givenName: billingAddress.firstName,
              surname: billingAddress.lastName,
              phoneNumber: billingAddress.phone,
              streetAddress: billingAddress.address,
              locality: billingAddress.city,
              region: billingAddress.state,
              postalCode: billingAddress.zip,
              countryCodeAlpha2: billingAddress.countryCode
            },
            challengeRequested: true
          })

          return nonce
        }
      }

      setHostedFields(customHostedFields)
    }).catch(setError)
      .finally(() => { setLoading(false) })
  }, [])

  return [hostedFields, error, loading, valid]
}

export { useBraintreeHostedFields, CustomHostedFields }
