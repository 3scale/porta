// eslint-disable-next-line @typescript-eslint/consistent-type-definitions
export type BillingAddressData = {
  firstName: string;
  lastName: string;
  address: string;
  city: string;
  country: string;
  company: string;
  phone: string;
  state: string; // ISO-3166-2 code
  zip: string;
}

// HACK: this type is a total hack. verifyCard requires this code, not the country name so we add it to billingAddress when a country is selected.
export type BillingAddress = BillingAddressData & {
  countryCodeAlpha2?: string;
}

export interface BraintreeFormDataset {
  billingAddress: BillingAddressData;
  clientToken: string;
  countriesList: [string, string][];
  formActionPath: string;
  threeDSecureEnabled: boolean;
}
