// eslint-disable-next-line @typescript-eslint/ban-ts-comment
// @ts-nocheck

const $ = window.$

export default function (): void { /* eslint-disable */
  // disable links with 'data-disabled' attribute and display alert instead
  // delegation on body fires before rails.js
  $('body').delegate('a[data-disabled]', 'click', function (event) {
    event.preventDefault()
    event.stopImmediatePropagation()
    alert($(this).data('disabled'))
    return false
  })

  ;(function () {
    if ($('#plan-select').length == 0) return
    const currentPlanID = $('#plans-selector').attr('data-plan-id')
    const $plans = $('div.plan-preview')

    $('#plan-select')[0].options[0].value
    const options = $('#plan-select')[0].options

    for (let i = options.length - 1; i >= 0; i--) {
      if (options[i].value == currentPlanID) {
        options.selectedIndex = (i - length)
      }
    }

    function attachEvents () {
      $('#plan-select').change(function () {

        const planID = this.options[this.selectedIndex].value
        $plans.hide()
        $('div.plan-preview[data-plan-id="' + planID + '"]').show()

        // HACK HACK HACK - redo the plan selector!
        if ($('#plans-selector').attr('data-plan-id') == planID) {
          $('#plan-change-submit').hide()
        } else {
          $('#plan-change-submit').show()
        }

        return false
      })
    }

    attachEvents()
  })()

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

  $(document).on('click', 'a.fancybox, a.colorbox', function (e) {
    $(this).colorbox({ open: true })
    e.preventDefault()
  })

  $(document).on('click', '.fancybox-close', function () {
    $.colorbox.close()
    return false
  })

  // Show panel on click.
  $('a.show-panel').click(function () {
    findPanel($(this)).fadeIn('fast')
    return false
  })

  // Hide panel on click.
  $('a.hide-panel').click(function () {
    findPanel($(this)).fadeOut('fast')
    return false
  })

  // Toggle panel on click.
  $('a.toggle-panel').click(function () {
    const panel = findPanel($(this))

    if (panel.is(':visible')) {
      panel.fadeOut('fast')
    } else {
      panel.fadeIn('fast')
    }

    return false
  })

  const findPanel = function (link) {
    const id = link.attr('data-panel')

    if (id) {
      return $('#' + id)
    } else {
      return $(link.attr('href'))
    }
  }

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
