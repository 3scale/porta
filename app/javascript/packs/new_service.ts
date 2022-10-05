import { NewServiceFormWrapper } from 'NewService/components/NewServiceForm'
import { safeFromJsonString } from 'utilities/json-utils'

import type { Props } from 'NewService/components/NewServiceForm'

document.addEventListener('DOMContentLoaded', () => {
  const containerId = 'new_service_wrapper'
  const newServiceWrapper = document.getElementById(containerId)

  if (!newServiceWrapper) {
    throw new Error('The target ID was not found: ' + containerId)
  }

  const newServiceFormProps = safeFromJsonString<Props>(newServiceWrapper.dataset.newServiceData) as Props

  NewServiceFormWrapper(newServiceFormProps, containerId)
})
