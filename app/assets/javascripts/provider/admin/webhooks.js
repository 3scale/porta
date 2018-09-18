$(document)
  .on('click', "a[href='#webhooks-switch']", function() {
    var form = $(this).closest('form');
    var checkbox = form.find('input[type="hidden"][name="web_hook[active]"]');

    checkbox.val((checkbox.val() == '1') ? '0' : '1');
    checkbox.removeAttr('disabled');

    form.submit();
    return false;
  })
  .on('click', "button[data-ping-url]", function() {
    $.flash.notice('Pinging...');
    $.ajax({ url: $(this).data('ping-url')});

    // jump to top
    window.location.hash = 'flashWrapper';

    return false;
  });
