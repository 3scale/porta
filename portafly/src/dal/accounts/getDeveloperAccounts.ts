import { useFetch } from 'react-async'
import { IDeveloperAccount } from 'types'

type User = {
  id: string
  created_at: string
  updated_at: string
  account_id: string
  state: string
  role: string
  username: string
  email: string
  first_name: string
  last_name: string
  extra_fields: any[]
}

type BuyersAccount = {
  account: { // TODO: remove this
    id: number
    created_at: string
    updated_at: string
    state: string
    deletion_date: string
    admin_domain: string
    domain: string
    from_email: string
    support_email: string
    finance_support_email: string
    site_access_code: string
    org_name: string
    org_legaladdress: string
    billing_address: {
      company: string
      address: string
      address1: string
      address2: string
      phone_number: string
      city: string
      country: string
      state: string
      zip: string
    }
    extra_fields: any[]
    credit_card_stored: boolean
    plans: any[]
    users: User[]
  }
}

interface Response<T> {
  accounts?: T,
  error?: Error
  isPending: boolean
}

/**
 * Get all Applications asynchronously
 * @returns An object containing: { accounts, error, isPending }
 */
function useGetDeveloperAccounts(): Response<IDeveloperAccount[]> {
  const params = new URLSearchParams({
    access_token: '[TOKEN]',
    page: '1',
    perPage: '500'
  })

  const { data, error, isPending } = useFetch<{ accounts: BuyersAccount[] }>(
    `https://multitenant-admin.preview01.3scale.net/admin/api/accounts.json?${params.toString()}`,
    { headers: { Accept: 'application/json' } }
  )

  const accounts = data && data.accounts.map(({ account }) => ({
    id: account.id,
    created_at: account.created_at,
    updated_at: account.updated_at,
    org_name: account.org_name,
    admin_name: account.billing_address.company,
    apps_count: 0, // TODO: this is not included in /admin/api/accounts
    state: account.state
  }))

  return { accounts, error, isPending }
}

export { useGetDeveloperAccounts }
