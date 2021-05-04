// @flow

export type BillingAddressData = {
  address: string,
  address1: string,
  address2: string,
  city: string,
  company: string,
  country: string,
  phone_number: string,
  state: string,
  zip: string,
}

export type BraintreeFormProps = {
  // eslint-disable-next-line flowtype/no-weak-types
  braintreeClient: any,
  billingAddress: BillingAddressData,
  threeDSecureEnabled: boolean,
  formActionPath: string,
  countriesList: string,
  selectedCountryCode: string
}
