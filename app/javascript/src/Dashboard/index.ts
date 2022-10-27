import $ from 'jquery'
import 'Dashboard/chart'

export function widget (url: string): void {
  void $.ajax({
    url: url,
    dataType: 'script',
    cache: true
  }).fail((xhr, status, error) => {
    if (!xhr.status) {
      // https://github.com/rollbar/rollbar.js/blob/1ba9c6bae2e9155578791628764a216affdd198c/src/plugins/jquery.js#L41-L45
      // user navigated out of the page
      return
    }

    throw new Error(`Failed to load ${url} with ${error} (${status})`)
  })
}
