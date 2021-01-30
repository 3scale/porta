// @flow

export type ApplicationPlan = {
  id: number,
  name: string,
}

export type Product = {
  id: number,
  name: string,
  appPlans: ApplicationPlan[]
}
