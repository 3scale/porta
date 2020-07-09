import { craftRequest, postData } from 'utils'
import { DeferFn } from 'react-async'

type CreateProductParams = {
  name: string
  description?: string
  deployment_option?: string
  backend_version?: string
  system_name?: string
}

export interface NewProduct {
  service: {
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
}

export type CreateProductValidationErrors = {
  name?: string[],
  system_name?: string[]
}

const createProduct: DeferFn<NewProduct> = async ([data]) => {
  const request = craftRequest('/admin/api/services.json')
  return postData(request, data)
}

export { createProduct }
