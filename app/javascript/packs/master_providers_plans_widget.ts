import $ from 'jquery'

import type { AJAXCompleteEvent } from 'Types/rails-ujs'

/**
 * DEPRECATED: replace jquery/colorbox modals with Patternfly modals.
 * TODO: add a more specific selector to separate this form from all other "remote" ones.
 */
$(document).on('ajax:complete', 'form.colorbox[data-remote]', (event) => {
  const [xhr] = (event.originalEvent as AJAXCompleteEvent).detail

  window.$.colorbox({
    open: true,
    html: xhr.responseText,
    maxWidth: '85%',
    maxHeight: '90%'
  })
})
