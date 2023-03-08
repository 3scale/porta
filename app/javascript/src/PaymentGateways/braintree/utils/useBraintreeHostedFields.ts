/* eslint-disable no-fallthrough, @typescript-eslint/no-throw-literal --
   TODO: current implementation assumes a generic error when verify card fails and liability is not shifted.
   However, each case is special and we should give proper feedback for each one. For instance there is a big
   difference between "unsupported card type" and "Wrong billing address".
*/

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

const CC_ERROR_MESSAGE = 'An error occurred, please review your CC details or try later.'

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
          const hostedFieldsTokenizePayload = await hostedFieldsInstance.tokenize()

          if (!threeDSecureEnabled) {
            return hostedFieldsTokenizePayload.nonce
          }

          const threeDSecureVerifyPayload = await verifyCard(threeDSecureInstance, {
            nonce: hostedFieldsTokenizePayload.nonce,
            bin: hostedFieldsTokenizePayload.details.bin,
            // @ts-expect-error Outdated types. {amount} is a string: https://braintree.github.io/braintree-web/current/ThreeDSecure.html#verifyCard
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
          }).catch((verifyCardError: BraintreeError) => {
            console.error({ verifyCardError })
            throw { message: CC_ERROR_MESSAGE }
          })

          // This information should be verified on the server by using the payment
          // method nonce find method. The values provided here are merely for convenience.
          // Only values looked up on the server should determine the logic about how to
          // process a transaction.
          const { threeDSecureInfo, nonce } = threeDSecureVerifyPayload

          // @ts-expect-error Outdated types. {status} is part of info: https://braintree.github.io/braintree-web/current/ThreeDSecure.html#~verifyPayload
          const { liabilityShifted, liabilityShiftPossible, status } = threeDSecureInfo

          if (liabilityShifted) {
            // Liability has shifted
            /*
              case 'authenticate_successful':
                // Cardholder enrolled, authentication successful, and
                // signature verification successful.

              case 'authenticate_attempt_successful':
                // The provided card brand authenticated this 3D
                // Secure transaction without password confirmation
                // from the customer.
            */
            return nonce

          } else if (liabilityShiftPossible) {
            // Liability may still be shifted
            // Decide if you want to submit the nonce
            switch (status) {
              case 'authenticate_unable_to_authenticate':
                // Authentication unavailable for this transaction.

              case 'challenge_required':
                // Authentication unavailable for this transaction.
                // Example use case: user cancels OTP modal

              case 'data_only_successful':
                // The data-only 3D Secure call was successfully
                // created. The dataOnlyRequested flag must be
                // sent to receive a successful response.

              default:
                console.error({ threeDSecureVerifyPayload })
                throw { message: CC_ERROR_MESSAGE }
            }
          } else {
            // Liability has not shifted and will not shift
            // Decide if you want to submit the nonce
            switch (status) {
              case 'authenticate_frictionless_failed':
                // Cardholder enrolled, authentication unsuccessful.
                // Merchants should prompt customers for another
                // form of payment.

              case 'authenticate_attempt_successful':
                // The provided card brand authenticated this 3D
                // Secure transaction without password confirmation
                // from the customer.

              case 'authenticate_rejected':
                // Authentication unsuccessful. Merchants should
                // prompt customers for another form of payment.

              case 'authentication_unavailable':
                // Authentication unavailable for this transaction.

              case 'lookup_error':
                // An error occurred while attempting to lookup
                // enrollment.

              case 'lookup_failed_acs_error':
                // Attempting to lookup enrollment resulted in a
                // timeout.

              case 'lookup_bypassed':
                // Bypass used to simulate a scenario where merchant
                // has elected to bypass the consumer authentication
                // flow via CardinalCommerce Rules Engine configuration.

              case 'authenticate_error':
                // An error occurred while attempting to authenticate.
                // Alternatively, merchants can ask customers for an
                // alternative form of payment.

                // Actually, this use case throws BraintreeError with code THREEDS_CARDINAL_SDK_ERROR
              default:
                console.error({ threeDSecureVerifyPayload })
                throw { message: CC_ERROR_MESSAGE }
            }
          }
        }
      }

      setHostedFields(customHostedFields)
    }).catch((useBraintreeHostedFieldsError: BraintreeError) => {
      console.error({ useBraintreeHostedFieldsError })
      setError(useBraintreeHostedFieldsError)
    })
      .finally(() => { setLoading(false) })
  }, [])

  return [hostedFields, error, loading, valid]
}

export { useBraintreeHostedFields, CustomHostedFields }
