import $ from 'jquery'

window.ThreeScale = {
  activeAjaxRequests: () => $.active + window.$.active,
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
