// @flow

export type ServicePlan = {
  id: number,
  name: string,
  default: boolean
}

export type ApplicationPlan = {
  id: number,
  name: string,
  serviceName: string,
  contractedServicePlan: ?ServicePlan,
  servicePlans: ?ServicePlan[]
}

export type UserDefinedField = {
  name: string,
  label: string,
  hidden: boolean,
  required: boolean
}
