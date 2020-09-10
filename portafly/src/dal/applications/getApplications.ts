import { craftRequest, fetchData } from 'utils'
import { IProductApplication, State } from 'types'

type Application = {
  application: {
    id: number,
    state: string,
    enabled: boolean,
    created_at: string,
    updated_at: string,
    service_id: number,
    service_name: string,
    plan_id: number,
    plan_name: string,
    account_id: number,
    org_name: string,
    first_traffic_at: string,
    first_daily_traffic_at: string,
    user_key: string,
    provider_verification_key: string,
    links: Array<{
      rel: string,
      href: string
    }>,
    name: string,
    description: string
  }
}

type Response = {
  applications: Array<Application>
}

const parseApplications = (applications: Application[]) => applications.map(({ application }) => ({
  id: application.id,
  name: application.name,
  state: application.state as State,
  account: {
    id: application.account_id,
    orgName: application.org_name
  },
  plan: {
    id: application.plan_id,
    name: application.plan_name
  },
  created_on: application.created_at,
  traffic_on: application.first_daily_traffic_at
}))

const getApplications = async (): Promise<IProductApplication[]> => {
  const request = craftRequest('/admin/api/applications.json')
  const data = await fetchData<Response>(request)
  return parseApplications(data.applications)
}

export { getApplications }
