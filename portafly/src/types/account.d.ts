export interface IDeveloperAccount extends IAccount {
  adminName: string
  createdAt: string // TODO: Find a specific date as string type
  state: State
  updatedAt: string
}

export interface IAccountOverview extends IDeveloperAccount {
  publicDomain: string
  adminDomain: string
  applications: any[]
  planName: string
  adminEmail: string
  state: State
}

export interface IAccount {
  id: number
  orgName: string
}
