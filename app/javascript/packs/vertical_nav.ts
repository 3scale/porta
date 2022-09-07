import {VerticalNavWrapper as VerticalNav} from 'Navigation/components/VerticalNav';
import { safeFromJsonString } from 'utilities'

document.addEventListener('DOMContentLoaded', () => {
  const container = document.getElementById('vertical-nav-wrapper')

  if (!container) {
    return
  }

  const { activeItem, activeSection, currentApi, sections } = container.dataset

  VerticalNav({
    sections: safeFromJsonString(sections) || [],
    activeSection,
    activeItem,
    currentApi: safeFromJsonString(currentApi) },
  'vertical-nav-wrapper'
  )
})
