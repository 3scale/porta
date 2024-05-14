$(document)
  .on('click', "a[href='#webhooks-switch']", function() {
    var form = $(this).closest('form');
    var checkbox = form.find('input[type="hidden"][name="web_hook[active]"]');

    checkbox.val((checkbox.val() == '1') ? '0' : '1');
    checkbox.removeAttr('disabled');

    form.submit();
    return false;
  })
