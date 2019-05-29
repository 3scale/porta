import {NewServiceFormWrapper} from 'NewService'
import {safeFromJsonString} from 'utilities/json-utils'

document.addEventListener('DOMContentLoaded', () => {
  const newServiceWrapper = document.getElementById('new_service_wrapper')
  const newServiceFormProps = safeFromJsonString(newServiceWrapper.dataset.newServiceData)

  NewServiceFormWrapper(newServiceFormProps, 'new_service_wrapper')
})
