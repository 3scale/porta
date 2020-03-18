import { useFetch } from 'react-async'
import { IDeveloperAccount } from 'types'

/**
 * Get all Applications asynchronously
 * @returns An object containing: { accounts, error, isPending }
 */
function useGetDeveloperAccounts() {
  const { data, error, isPending } = useFetch<[IDeveloperAccount]>(
    '/developer/accounts',
    { headers: { Accept: 'application/json' } }
  )

  return { accounts: data, error, isPending }
}

export { useGetDeveloperAccounts }
