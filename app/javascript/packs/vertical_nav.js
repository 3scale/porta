import { VerticalNavWrapper as VerticalNav } from 'Navigation/components/VerticalNav'
import { safeFromJsonString } from 'utilities/json-utils'

const containerId = 'api_selector'

document.addEventListener('DOMContentLoaded', () => {
  const dataset = document.getElementById('vertical-nav-wrapper').dataset
  const sections = safeFromJsonString(dataset.sections)
  const activeSection = dataset.active_section
  const activeItem = dataset.active_item

  const apiSelector = document.getElementById(containerId)
  const { currentApi } = apiSelector.dataset

  console.log('what is the sections' + sections + JSON.stringify(sections))
  console.log('what is the activeSection' + sections + JSON.stringify(activeSection))

  // TODO: where does this go?
  // - if can?(:manage, :plans)
  //   { title: 'Integration Errors', path: admin_service_errors_path(@service) },
  VerticalNav({ sections, activeSection, activeItem, currentApi: JSON.parse(currentApi) }, 'vertical-nav-wrapper')
})
