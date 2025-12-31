import $ from 'jquery'

import { render } from 'Dashboard/chart'
import { toast, hideToast } from 'utilities/toast'

window.ThreeScale = {
  activeAjaxRequests: () => $.active + window.$.active,
  toast,
  hideToast,
  renderChartWidget: render,
  spinnerId: 'ajax-in-progress',
  showSpinner: () => {
    if (document.getElementById(window.ThreeScale.spinnerId) === null) {
      document.body.insertAdjacentHTML(
        'afterbegin',
        `<div id="${window.ThreeScale.spinnerId}"><img src="/assets/ajax-loader.gif"></div>`
      )
    }
  },
  hideSpinner: () => { document.getElementById(window.ThreeScale.spinnerId)?.remove() }
}
