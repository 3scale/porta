import { VerticalNavWrapper as VerticalNav } from 'Navigation/components/VerticalNav'

import '@patternfly/react-core/dist/styles/base.css'

document.addEventListener('DOMContentLoaded', () => {
  const itemGroups = {
    analytics: [
      { title: 'Usage', path: '' },
      { title: 'Daily Averages', path: '' },
      { title: 'Hourly Averages', path: '' },
      { title: 'Top Applications', path: '' },
      { title: 'Response Codes', path: '' },
      { title: 'Alerts', path: '' }
    ],
    billing: [
      { title: '3scale Invoices', path: '' },
      { title: 'Payment Details', path: '' }
    ]
  }

  // - if can?(:manage, :plans)
  //   { title: 'Integration Errors', path: admin_service_errors_path(@service) },
  VerticalNav({
    itemGroups
  }, 'vertical-nav-wrapper')
})
