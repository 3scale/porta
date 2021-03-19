// @flow

export * from 'Types/Api'
export * from 'Types/NavigationTypes'
export * from 'Types/FlashMessages'
export * from 'Types/Signup'

export type ApplicationPlan = {
  id: number,
  name: string,
}

export type Product = {
  id: number,
  name: string,
  appPlans: ApplicationPlan[]
}

export type Backend = {
  id: number,
  name: string,
  privateEndpoint: string
}
