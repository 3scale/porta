import { craftRequest, deleteData } from 'utils'
import { DeferFn } from 'react-async'

const deleteProduct: DeferFn<void> = async ([productId]) => {
  const request = craftRequest(`/admin/api/services/${productId}.json`)
  return deleteData(request)
}

export { deleteProduct }
