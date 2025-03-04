import $ from 'jquery'

/**
 * Set up remote forms and links with ajax. Origin: app/assets/javascripts/remote.js
 */
export default function remote (): void {
  const addAcceptHeader = function (xhr: JQuery.jqXHR) {
    xhr.setRequestHeader('Accept', 'text/javascript, text/html, application/xml, text/xml, */*')
  }

  $(document).on('submit', 'form.remote', (event: JQuery.TriggeredEvent) => {
    const form = event.target as HTMLFormElement
    const $form = $(form)
    const $buttons = $form.find('input[type=submit], button[type=submit]')

    void $.ajax({
      type: form.method,
      url: form.action,
      data: $form.serializeArray(),
      beforeSend: addAcceptHeader,
      complete: () => { $buttons.prop('disabled', false) }
    })

    $buttons.prop('disabled', true)

    return false
  })

  $(document).on('click', 'a.remote', (event: JQuery.TriggeredEvent) => {
    const link = event.target as HTMLAnchorElement
    const $link = $(link)

    void $.ajax({
      url: link.href,
      beforeSend: addAcceptHeader,
      complete: () => { $link.prop('disabled', false) }
    })

    $link.prop('disabled', true)

    return false
  })
}
