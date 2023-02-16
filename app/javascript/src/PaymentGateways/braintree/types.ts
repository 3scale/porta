export interface BillingAddressData {
  address: string;
  city: string;
  company: string;
  country: string;
  state: string;
  zip: string;
}

export interface BraintreeFormDataset {
  billingAddress: BillingAddressData;
  clientToken: string;
  countriesList: [string, string][];
  errors: unknown;
  formActionPath: string;
  threeDSecureEnabled: boolean;
  selectedCountryCode: string;
}

export interface HostedFieldsOptions {
  styles: Record<string, Record<string, unknown> | string>;
  fields: Record<string, {
    selector: string;
    placeholder: string;
  }>;
}
