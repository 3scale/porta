import { craftRequest, fetchData } from 'utils'

const approveAccount = async (id: string): Promise<void> => {
  const request = craftRequest(`admin/api/accounts/${id}/approve.xml`)
  return fetchData<void>(request)
}

export { approveAccount }
