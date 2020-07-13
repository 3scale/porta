import { craftRequest, fetchData } from 'utils'
import { PromiseFn } from 'react-async'
import { IProductOverview } from 'types'

export interface Product {
  id: number,
  name: string,
  state: string,
  system_name: string,
  backend_version: string,
  deployment_option: string,
  support_email: string,
  description: string,
  intentions_required: boolean,
  buyers_manage_apps: boolean,
  buyers_manage_keys: boolean,
  referrer_filters_required: boolean,
  custom_keys_enabled: boolean,
  buyer_key_regenerate_enabled: boolean,
  mandatory_app_key: boolean,
  buyer_can_select_plan: boolean,
  buyer_plan_change_permission: string,
  created_at: string,
  updated_at: string,
  links: Array<{ rel: string, href: string }>
}

type Response = { service: Product }

const parseProduct = (product: Product) => ({
  id: product.id,
  name: product.name,
  systemName: product.system_name,
  description: product.description
})

const getProduct: PromiseFn<IProductOverview> = async ({ productId }) => {
  const request = craftRequest(`/admin/api/services/${productId}.json`, new URLSearchParams({
    page: '1',
    perPage: '500'
  }))
  const data = await fetchData<Response>(request)
  return parseProduct(data.service)
}

export { getProduct }
