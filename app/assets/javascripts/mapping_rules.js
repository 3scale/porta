jQuery(document).ready(function(){
  jQuery('#proxy-rules .metric select[data-selected]').each(function () {
    jQuery(this).val(jQuery(this).data('selected'))
  });

  jQuery(function () {
    var PIXEL_CORRECTOR = 4
    var tdWidths = jQuery.map(jQuery('.ui-sortable-item').first().children(), function (td, _i) {
      return td.offsetWidth + PIXEL_CORRECTOR
    })
    jQuery(function () {
      jQuery('#sortable').sortable({
        cursor: 'move',
        containment: '#mapping-rules',
        items: 'tr:not(#new-proxy-rule-template)',
        start: function (event, ui) {
          jQuery.each(ui.item.children(), function (i, td) {
            jQuery(td).css({ width: tdWidths[i] })
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
      jQuery('tr, td').disableSelection()
    })
  })
});
