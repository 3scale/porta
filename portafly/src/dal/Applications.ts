import { useFetch } from 'react-async'
import { IApplication } from 'types'

/**
 * Get all Applications asynchronously
 * @returns An object containing: { applications, error, isPending }
 */
function useGetApplications () {
  const { data, error, isPending } = useFetch<[IApplication]>(
    '/applications',
    { headers: { Accept: 'application/json' } }
  )

  return { applications: data, error, isPending }
}

export { useGetApplications }
