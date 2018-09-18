;(function($) {

  var handle_checkboxes = function () {
    var table = $('table.data'),
        selectTotalEntries = $('#bulk-operations a.select-total-entries');

    // select all checkbox
    table.find('thead .select .select-all').live('change', function(){
      $(this).closest('table').
        find('tbody .select input[type=checkbox]').
        attr('checked', $(this).is(':checked')).
        trigger('change');
    });

    // single checkbox
    table.find('tbody .select input[type=checkbox]').live('change', function(){
      var $this = $(this);
      var row   = $this.closest('tr');
      var bulk  = $('#bulk-operations');

      if($this.is(':checked')) {
        row.addClass('selected');
      } else {
        row.removeClass('selected');
      }

      var selected = row.closest('tbody, table').find('.selected').length;

      if(selected > 0) {
        // show bulk operations section
        bulk.slideDown();
        // show selected count
        bulk.find('.count').text(selected);
        // if user has selected all checkboxes -> show select total entries action
        if (selected == table.find('tbody .select input[type=checkbox]').length) {
          selectTotalEntries.show();
        } else {
          // total entries action back to the default state
          selectTotalEntries.hide();
          selectTotalEntries.text(selectTotalEntries.data('default-text'));
          selectTotalEntries.removeAttr('data-selected-total-entries');
        }
      } else {
        // hide bulk operations section
        bulk.slideUp();
      }
    });
  }

  var prepare_operations = function() {
    var operations = $("#bulk-operations");
    operations.
      live('bulk:success', function(){
        $.colorbox({
          html: '<h1>Action completed successfully</h1>',
          title: 'Bulk operation completed successfully'
        });
    }).
      find('.operation').each(function(){
        var operation = $(this);
        $(this).wrapInner('<button>');
        $(this).find('button').colorbox({
          href: function(){
            var urlParts = [operation.data('url'), $('table.data tbody .select :checked').serialize()],
                url      = null;

            // url address might already inludes some parameters
            if(urlParts[0].indexOf('?') > -1) {
              url = urlParts.join('&');
            } else {
              url = urlParts.join('?');
            }

            // if total entries action was selected
            // add selected_total_entries parameter to the url
            var selectTotalEntries = $('#bulk-operations a.select-total-entries');            
            if (selectTotalEntries.length && selectTotalEntries.attr('data-selected-total-entries')) {
              url += '&selected_total_entries=true';
            }

            return url;
          },
          title: operation.next('.description').text(),
          autoDimensions: true,
          overlayShow: true, // cannot use modal, because its setting cannot be overriden
          hideOnOverlayClick: false,
          hideOnContentClick: false,
          enableEscapeButton: false,
          showCloseButton: true
        });
    });
  }

  var handle_selectTotalEntries = function() {
    $('#bulk-operations a.select-total-entries').live('click', function(e) {
      e.preventDefault();

      var $this    = $(this),
          attrName = 'data-selected-total-entries';

      if ($this.attr(attrName)) {
        // user has already selected total entries
        $this.removeAttr(attrName);
        // set back the default text
        $this.text($this.data('default-text'));
      } else {
        // save information that user has selected total entries
        $this.attr(attrName, true);
        // save default text
        $this.data('default-text', $this.text());
        // new text for the link
        var newText = '(only select the ';
        newText += $('table.data tr.selected').length;
        newText += ' ';
        newText += $this.data('association-name');
        newText += ' on this page)';

        $this.text(newText);
      }

    });
  }

  $(function(){
    prepare_operations();
    handle_checkboxes();
    handle_selectTotalEntries();
  });

})(jQuery);
