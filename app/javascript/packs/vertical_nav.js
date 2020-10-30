import { VerticalNavWrapper as VerticalNav } from 'Navigation/components/VerticalNav'
import { safeFromJsonString } from 'utilities/json-utils'

document.addEventListener('DOMContentLoaded', () => {
  const dataset = document.getElementById('vertical-nav-wrapper').dataset
  const sections = safeFromJsonString(dataset.sections)
  const activeSection = dataset.active_section
  const activeItem = dataset.active_item
  const currentApi = dataset.current_api

  // TODO: where does this go?
  // - if can?(:manage, :plans)
  //   { title: 'Integration Errors', path: admin_service_errors_path(@service) },
  VerticalNav({ sections, activeSection, activeItem, currentApi: safeFromJsonString(currentApi) }, 'vertical-nav-wrapper')
})
