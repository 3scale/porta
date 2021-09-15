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
  id: string,
  name: string,
  description?: string,
  updatedAt: string,
  appPlans: ApplicationPlan[],
  servicePlans: ServicePlan[],
  defaultServicePlan?: ServicePlan,
  defaultAppPlan?: ApplicationPlan,
  buyerCanSelectPlan?: boolean
}

export type ContractedProduct = {
  id: number,
  name: string,
  withPlan: ServicePlan
}

export type Buyer = {
  id: string,
  name: string,
  description?: string,
  createdAt: string,
  contractedProducts: ContractedProduct[],
  createApplicationPath: string,
}

export type FetchItemsRequestParams = $Exact<{
  page: number,
  perPage: number,
  query?: string
}>

export type FetchItemsResponse<T> = Promise<{ items: T[], count: number }>
