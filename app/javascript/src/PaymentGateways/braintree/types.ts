export interface BillingAddressData {
  address: string;
  address1: string;
  address2: string;
  city: string;
  company: string;
  country: string;
  // eslint-disable-next-line @typescript-eslint/naming-convention
  phone_number: string;
  state: string;
  zip: string;
}

export interface HostedFieldsOptions {
  styles: Record<string, Record<string, unknown> | string>;
  fields: Record<string, {
    selector: string;
    placeholder: string;
  }>;
}
