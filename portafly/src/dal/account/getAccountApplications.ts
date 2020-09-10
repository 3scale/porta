import { craftRequest, fetchData } from 'utils'
import { IAccountApplication, State } from 'types'
import { PromiseFn } from 'react-async'

type Application = {
  application: {
    id: number
    state: string
    enabled: boolean
    created_at: string
    updated_at: string
    service_id: number
    service_name: string // FIXME: add this to the endpoint response
    plan_id: number
    plan_name: string
    account_id: number
    first_traffic_at: string
    first_daily_traffic_at: string
    user_key: string
    provider_verification_key: string
    links: Array<{
      rel: string,
      href: string
    }>,
    name: string,
    description: string
  }
}

const parseApplications = (applications: Application[]) => applications.map(({ application }) => ({
  id: application.id,
  name: application.name,
  state: application.state as State,
  product: {
    id: application.service_id,
    name: application.service_name
  },
  plan: {
    id: application.plan_id,
    name: application.plan_name
  },
  createdOn: application.created_at,
  trafficOn: application.first_daily_traffic_at
}))

const getAccountApplications: PromiseFn<IAccountApplication[]> = async ({ accountId }) => {
  const request = craftRequest(`/admin/api/accounts/${accountId}/applications.json`)
  const data = await fetchData<{ applications: Application[] }>(request)
  return parseApplications(data.applications)
}

export { getAccountApplications }
