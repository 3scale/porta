export interface BillingAddress {
  firstName: string;
  lastName: string;
  address: string;
  city: string;
  country: string;
  countryCode: string; // ISO-3166-2 code
  company: string;
  phone: string;
  state: string; // ISO-3166-2 code
  zip: string;
}

export interface BraintreeFormDataset {
  billingAddress: BillingAddress;
  clientToken: string;
  countriesList: [string, string][];
  formActionPath: string;
  threeDSecureEnabled: boolean;
}
