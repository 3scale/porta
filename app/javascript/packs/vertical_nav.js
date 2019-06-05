import { VerticalNavWrapper as VerticalNav } from 'Navigation/components/VerticalNav'
import { safeFromJsonString } from 'utilities/json-utils'

import '@patternfly/react-core/dist/styles/base.css'

document.addEventListener('DOMContentLoaded', () => {
  const dataset = document.getElementById('vertical-nav-wrapper').dataset
  const sections = safeFromJsonString(dataset.sections)

  // - if can?(:manage, :plans)
  //   { title: 'Integration Errors', path: admin_service_errors_path(@service) },
  VerticalNav({
    sections
  }, 'vertical-nav-wrapper')
})
