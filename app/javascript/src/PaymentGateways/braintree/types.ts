export type BillingAddressData = {
  address: string,
  address1: string,
  address2: string,
  city: string,
  company: string,
  country: string,
  // eslint-disable-next-line camelcase
  phone_number: string,
  state: string,
  zip: string
}

export type HostedFieldsOptions = {
  styles: Record<string, string | Record<any, any>>,
  fields: Record<string, {
    selector: string,
    placeholder: string
  }>
}
