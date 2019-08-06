$(document).ready(function () {
  $('#proxy-rules .metric select[data-selected]').each(function () {
    $(this).val($(this).data('selected'))
  })

  $(function () {
    var PIXEL_CORRECTOR = 4
    var tdWidths = $.map($('.ui-sortable-item').first().children(), function (td, _i) {
      return td.offsetWidth + PIXEL_CORRECTOR
    })
    $(function () {
      $('#sortable').sortable({
        cursor: 'move',
        containment: '#mapping-rules',
        items: 'tr:not(#new-proxy-rule-template)',
        start: function (event, ui) {
          $.each(ui.item.children(), function (i, td) {
            $(td).css({ width: tdWidths[i] })
          })
        },
        stop: function () {
          $('tr:not(#new-proxy-rule-template)', this).each(function (index, mappingRule) {
            if (!$(mappingRule).hasClass('deleted')) {
              $(mappingRule).find('select,input:not(.destroyer)').removeAttr('disabled')
              $(mappingRule).find('span.fa-exclamation-triangle').removeClass('disabled')
            }
            $(mappingRule).find('.position').val(index + 1)
          })
        }
      })
      $('tr, td').disableSelection()
    })
  })
})
