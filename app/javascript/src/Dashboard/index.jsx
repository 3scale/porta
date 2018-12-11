import $ from 'jquery'

import 'Dashboard/chart'
import toggle from 'Dashboard/toggle'

export { toggle }

export function widget (url) {
  $.ajax({
    url: url,
    dataType: 'script',
    cache: true
  }).fail((xhr, status, error) => {
    if (!xhr.status) {
      // https://github.com/rollbar/rollbar.js/blob/1ba9c6bae2e9155578791628764a216affdd198c/src/plugins/jquery.js#L41-L45
      // user navigated out of the page
      return
    }

    let errorception = window._errs
    let exception = new Error(`Failed to load ${url} with ${error} (${status})`)

    if (errorception) {
      let meta = errorception.meta
      errorception.meta = { code: xhr.status, body: xhr.responseText, status: status, error: error, url: url }
      errorception.push(exception)
      errorception.meta = meta
    } else {
      throw exception
    }
  })
}
