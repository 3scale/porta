// import type { Product as BaseProduct } from 'Types'

type ProductLink = {
  name: 'Edit' | 'Overview' | 'Analytics' | 'Applications' | 'ActiveDocs' | 'Integration',
  path: string
}

export type Product = {
  id: number,
  name: string,
  systemName: string,
  updatedAt: string,
  links: Array<ProductLink>,
  appsCount: number,
  backendsCount: number,
  unreadAlertsCount: number
}
