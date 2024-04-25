// eslint-disable-next-line @typescript-eslint/ban-ts-comment
// @ts-nocheck

const $ = window.$

export default function (): void { /* eslint-disable */
  // disable links with 'data-disabled' attribute and display alert instead
  // delegation on body fires before rails.js. FIXME: this is not a valid guard. If "data-disabled"
  // removed manually from the DOM, the request will still go through. The link should be disabled
  // (not clickable) and the server should return a flash error.
  $('body').delegate('a[data-disabled]', 'click', (event) => {
    alert((event.currentTarget as HTMLAnchorElement).dataset.disabled)
    return false
  })

  // DEPRECATED: since the introduction of PF4 and React, colorbox is being removed.
  // Response of this form will be presented inside a colorbox.
  $(document).on('submit', 'form.colorbox[data-remote]', function (e) {
    $(this).on('ajax:complete', function (event, xhr, status) {
      const form = $(this).closest('form')
      const width = form.data('width')
      $.colorbox({
        open: true,
        html: xhr.responseText,
        width: width,
        maxWidth: '85%',
        maxHeight: '90%'
      })
    })
  })

  // TODO: replace .fancybox with .colorbox
  // This link will load its content into a colorbox modal
  $(document).on('click', 'a.fancybox, a.colorbox', ({ currentTarget }) => {
    $(currentTarget).colorbox({ open: true })
    return false
  })

  // TODO: replace .fancybox with .colorbox
  // This is used in some modals with a "Cancel" button.
  $(document).on('click', '.fancybox-close', () => {
    $.colorbox.close()
    return false
  })

  // DEPRECATED: since the introduction of PF4 and React, colorbox is being removed. Also jquery-ujs has been replaced with rails-ujs.
  // Added #colorbox selector to target only non-React forms
  // show errors from ajax in formtastic
  $(document).on('ajax:error', 'form:not(.pf-c-form)', function (event, xhr, status, error) {
    switch (status) {
      case 'error':
        $.colorbox({ html: xhr.responseText })
        event.stopPropagation()
        break
    }
  })

  $(document).on('change', '#search_deleted_accounts', function () {
    $(this.form).submit()
  })
}
