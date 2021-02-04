// @flow

export type ServicePlan = {
  id: number,
  name: string
}

export type ApplicationPlan = {
  id: number,
  name: string,
}

export type Product = {
  id: number,
  name: string,
  systemName: string,
  updatedAt: string,
  appPlans: ApplicationPlan[],
  servicePlans: ServicePlan[],
  defaultServicePlan: ServicePlan | null
}

export type ContractedProduct = {
  id: number,
  name: string,
  withPlan: ServicePlan
}

export type Buyer = {
  id: string,
  name: string,
  contractedProducts: ContractedProduct[],
  createApplicationPath: string,
}
