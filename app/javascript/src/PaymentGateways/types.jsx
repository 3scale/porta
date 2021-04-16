// @flow

export type BraintreeFormProps = {
  clientToken: string,
  billingAddress?: string,
  threeDSecureEnabled: boolean,
  formActionPath: string,
  countriesList: string,
  selectedCountryCode?: string
}
