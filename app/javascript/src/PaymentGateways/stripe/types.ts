import type { PaymentMethodCreateParams } from '@stripe/stripe-js'

export type BillingAddress = PaymentMethodCreateParams.BillingDetails.Address

export interface StripeFormDataset {
  stripePublishableKey: string;
  setupIntentSecret: string;
  billingAddress: BillingAddress;
  billingName: string;
  successUrl: string;
  creditCardStored: boolean;
}
