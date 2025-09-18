import { safeFromJsonString } from 'utilities/json-utils'
import { CustomSupportEmailsWrapper as CustomSupportEmails } from 'SiteEmails/components/CustomSupportEmails'

import type { Props as EditPageProps } from 'SiteEmails/components/CustomSupportEmails'

document.addEventListener('DOMContentLoaded', () => {
  const containerId = 'custom-support-emails'
  const container = document.getElementById(containerId)

  if (!container) {
    throw new Error('Container with id ' + containerId + ' could not be found.')
  }

  const props = safeFromJsonString<EditPageProps>(container.dataset.props)

  if (!props) {
    throw new Error('Exception modal props not found and it will not be rendered.')
  }

  CustomSupportEmails(props, containerId)
})
