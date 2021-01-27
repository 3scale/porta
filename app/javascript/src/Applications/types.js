// @flow

export type ServicePlan = {
  id: number,
  name: string,
  issuer_id: number, // TODO: change to productId in app/helpers/buyers/applications_helper.rb:14
  default: boolean
}

export type ApplicationPlan = {
  id: number,
  name: string,
  issuer_id: number // TODO: change to productId in app/helpers/buyers/applications_helper.rb:14
}

export type Product = {
  id: number,
  name: string,
  appPlans: ApplicationPlan[],
  servicePlans: ServicePlan[],
  defaultServicePlan: ServicePlan | null
}

export type Buyer = {
  id: string,
  name: string,
  contractedProducts: Product[],
  // servicePlans: ServicePlan[], Not needed?
  createApplicationPath: string,
}
