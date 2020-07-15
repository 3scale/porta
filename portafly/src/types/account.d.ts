export interface IDeveloperAccount extends IAccount {
  adminName: string
  createdAt: string // TODO: Find a specific date as string type
  state: State
  updatedAt: string
}

export interface IAccount {
  id: number
  orgName: string
}
