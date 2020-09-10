import { craftRequest, fetchData } from 'utils'
import { IAccountOverview, State } from 'types'
import { PromiseFn } from 'react-async'

type Account = {
  id: number
  created_at: string
  updated_at: string
  credit_card_stored: boolean
  monthly_billing_enabled: boolean
  monthly_charging_enabled: boolean
  public_domain: string // FIXME: add this to the endpoint response
  admin_domain: string // FIXME: add this to the endpoint response
  plan_name: string // FIXME: add this to the endpoint response
  admin_name: string // FIXME: add this to the endpoint response
  admin_email: string // FIXME: add this to the endpoint response
  state: string
  links: Array<{
    rel: string,
    href: string
  }>
  org_name: string
}

const parseAccount = (account: Account) => ({
  publicDomain: account.public_domain,
  adminDomain: account.admin_domain,
  planName: account.plan_name,
  id: account.id,
  adminName: account.admin_name,
  adminEmail: account.admin_email,
  createdAt: account.created_at,
  state: account.state as State,
  updatedAt: account.updated_at,
  orgName: account.org_name,
  applications: []
})

const getAccount: PromiseFn<IAccountOverview> = async ({ accountId }) => {
  const request = craftRequest(`/admin/api/accounts/${accountId}.json`, new URLSearchParams({
    page: '1',
    perPage: '500'
  }))
  const data = await fetchData<{ account: Account }>(request)
  return parseAccount(data.account)
}

export { getAccount }
