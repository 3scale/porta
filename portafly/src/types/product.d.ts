export interface IProductOverview extends IProduct {
  description: string
}

export interface IProduct {
  id: number
  name: string
  systemName: string
}
