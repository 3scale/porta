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

export type FieldDefinition = {
  hidden: boolean,
  required: boolean,
  label: string,
  name: string,
  id: string,
  choices?: string[],
  hint?: string,
  readOnly: boolean,
  type: 'extra' | 'internal' | 'builtin'
}
