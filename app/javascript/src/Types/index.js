// @flow

export * from 'Types/Api'
export * from 'Types/NavigationTypes'
export * from 'Types/FlashMessages'
export * from 'Types/Signup'

export type Plan = {
  id: number,
  name: string
}

export type ApplicationPlan = Plan & {
  applications: number,
  state: string,
  actionPaths: {
    publish: string,
    copy: string,
    delete: string
  },
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
