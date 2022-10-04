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
  styles: {
    [key: string]: string | Record<any, any>
  },
  fields: {
    [key: string]: {
      selector: string,
      placeholder: string
    }
  }
}
