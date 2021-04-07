// @flow

import type { Method } from 'utilities/ajax'

export * from 'Types/Api'
export * from 'Types/NavigationTypes'
export * from 'Types/FlashMessages'
export * from 'Types/Signup'

export type Plan = {
  id: number,
  name: string
}

export type Action = {
  title: string,
  path: string,
  method: Method
}

export type ApplicationPlan = Plan & {
  applications: number,
  state: string,
  actions: Action[],
  editPath: string,
  applicationsPath: string
}

export type Product = {
  id: number,
  name: string,
  appPlans: Plan[]
}

export type Backend = {
  id: number,
  name: string,
  privateEndpoint: string
}
