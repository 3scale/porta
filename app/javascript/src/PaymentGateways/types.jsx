// @flow

export type BraintreeFormProps = {
  // eslint-disable-next-line flowtype/no-weak-types
  braintreeClient: any,
  billingAddress?: string,
  threeDSecureEnabled: boolean,
  formActionPath: string,
  countriesList: string,
  selectedCountryCode?: string
}
