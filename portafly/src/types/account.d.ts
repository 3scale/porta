export interface IDeveloperAccount extends IAccount {
  admin_name: string
  created_at: string // TODO: Find a specific date as string type
  state: string
  updated_at: string
}

export interface IAccount {
  id: number
  org_name: string
}
