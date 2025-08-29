import { safeFromJsonString } from 'utilities/json-utils'
import { EditPageWrapper as EditPage } from 'SiteEmails/components/EditPage'

import type { Props as EditPageProps } from 'SiteEmails/components/EditPage'

document.addEventListener('DOMContentLoaded', () => {
  const containerId = 'site-emails-edit'
  const container = document.getElementById(containerId)

  if (!container) {
    throw new Error('Container with id ' + containerId + ' could not be found.')
  }

  const props = safeFromJsonString<EditPageProps>(container.dataset.props)

  if (!props) {
    throw new Error('Exception modal props not found and it will not be rendered.')
  }

  EditPage(props, 'exceptions-stack')
})
