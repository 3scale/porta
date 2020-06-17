import { craftRequest, fetchData } from 'utils'
import { IDeveloperAccount } from 'types'

type BuyersAccount = {
  account: { // TODO: remove this
    id: number
    created_at: string
    updated_at: string
    org_name: string
    admin_display_name: string
    bought_cinstances_count: number
    state: string
  }
}

const parseAccounts = (accounts: BuyersAccount[]) => accounts.map(({ account }) => ({
  id: account.id,
  created_at: account.created_at,
  updated_at: account.updated_at,
  org_name: account.org_name,
  admin_name: account.admin_display_name,
  apps_count: account.bought_cinstances_count,
  state: account.state
}))

const getDeveloperAccounts = async (): Promise<IDeveloperAccount[]> => {
  const request = craftRequest('/admin/api/accounts.json', new URLSearchParams({
    page: '1',
    perPage: '500'
  }))
  const data = await fetchData<{ accounts: BuyersAccount[] }>(request)
  return parseAccounts(data.accounts)
}

export { getDeveloperAccounts }
