export interface IApplication {
  id: number
  name: string
  plan: IPlan
}

export interface IProductApplication extends IApplication {
  state: State
  account: IAccount
  created_on: string
  traffic_on: string
}
