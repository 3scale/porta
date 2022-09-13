/* eslint-disable flowtype/no-weak-types */

import type { ReactNode } from 'react'

export type BillingAddressData = {
  address: string,
  address1: string,
  address2: string,
  city: string,
  company: string,
  country: string,
  phone_number: string,
  state: string,
  zip: string
};

export type BraintreeFormProps = {
  braintreeClient: any,
  billingAddress: BillingAddressData,
  threeDSecureEnabled: boolean,
  formActionPath: string,
  countriesList: string,
  selectedCountryCode: string
};

export type BillingAddressProps = {
  countriesList: Array<string[]>,
  billingAddressData: BillingAddressData,
  setBillingAddressData: (obj: BillingAddressData) => void,
  selectedCountryCode: string
};

export type BraintreeSubmitFieldsProps = {
  onSubmitForm: (event: React.SyntheticEvent<HTMLInputElement>) => Promise<unknown> | undefined,
  isFormValid: boolean
};

export type InputProps = {
  id: string,
  required?: boolean,
  name: string,
  value: string,
  onChange?: (event: React.SyntheticEvent<HTMLInputElement>) => void
};

export type LabelProps = {
  htmlFor: string,
  label: string,
  required?: boolean
};

export type ListItemProps = {
  id: string,
  children?: Node
};

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
};
