(function ($) {
  $.flash = function (message) { $.flash.notice(message) }
  $.flash.timeout = 5000

  var timeouts = [],
    display_notice = function (message, clazz, opts) {
      var id
      while (id = timeouts.shift()) { clearTimeout(id) }

      $.flash.current = message

      var p = $('<p>')
      if (opts && opts.text) {
        p.text(message)
      } else {
        p.html(message)
      }

      $('.ajaxNoticeValid:first')
      .html(p.wrap('<div/>').parent().html())
      .removeClass('flash-message--error')
      .removeClass('flash-message')
      .addClass(clazz)

      $('#flashWrapper').css('display', '')

      if (!opts || (opts.hide !== false)) {
        timeouts.push(setTimeout($.flash.hide, $.flash.timeout))
      }
    }

  // TODO: replace with jquery-ui classes ui-state-highlight and ui-state-error
  $.flash.notice = function (message, opts) { display_notice(message, 'flash-message', opts) }
  $.flash.error = function (message, opts) { display_notice(message, 'flash-message flash-message--error', opts) }

  $.flash.hide = function () {
    $.flash.current = null
    $('#flashWrapper').fadeOut()
  }
})(jQuery)
