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

export interface IAccountApplication extends IApplication {
  state: State
  product: IProduct
  createdOn: string
  trafficOn: string
}
