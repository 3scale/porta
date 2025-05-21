import $ from 'jquery'

const jQuery1 = window.$

export default function (): void {
  // disable links with 'data-disabled' attribute and display alert instead
  // delegation on body fires before rails.js. FIXME: this is not a valid guard. If "data-disabled"
  // removed manually from the DOM, the request will still go through. The link should be disabled
  // (not clickable) and the server should return a flash error.
  $('body').on('click', 'a[data-disabled]', (event) => {
    event.preventDefault()
    event.stopImmediatePropagation()
    alert((event.currentTarget as HTMLAnchorElement).dataset.disabled)
  })

  // TODO: replace .fancybox with .colorbox
  // This link will load its content into a colorbox modal
  $(document).on('click', 'a.fancybox, a.colorbox', (e) => {
    jQuery1(e.currentTarget as HTMLAnchorElement).colorbox({ open: true })
    e.preventDefault()
  })

  // TODO: replace .fancybox with .colorbox
  // This is used in some modals with a "Cancel" button.
  $(document).on('click', '.fancybox-close', (e) => {
    jQuery1.colorbox.close()
    e.preventDefault()
    e.stopPropagation()
  })
}
