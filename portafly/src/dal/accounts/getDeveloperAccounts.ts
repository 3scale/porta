import { useFetch } from 'react-async'
import { IDeveloperAccount } from 'types'

/**
 * Get all Applications asynchronously
 * @returns An object containing: { accounts, error, isPending }
 */
function useGetDeveloperAccounts() {
  const { data, error, isPending } = useFetch<[IDeveloperAccount]>(
    'https://multitenant-admin.preview01.3scale.net/admin/api/accounts.json?access_token=[TOKEN]&page=1&per_page=500',
    { headers: { Accept: 'application/json' } }
  )

  return { accounts: data, error, isPending }
}

export { useGetDeveloperAccounts }
