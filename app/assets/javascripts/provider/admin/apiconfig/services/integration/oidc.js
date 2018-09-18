/* eslint-disable no-undef */
// eslint-disable-next-line spaced-comment
//= require 'message-bus'

$(function () {

  function unloadWarning(event) {
    var dialogText = "OpenID Connect Issuer verification in progress. You won't be able to see its status when you navigate away."
    event.returnValue = dialogText
    return dialogText
  }
  $('form.proxy-settings.oauth.oidc[data-gid]:has("input#proxy_oidc_issuer_endpoint")').each(function () {
    var gid = $(this).data('gid')
    var lastId = parseInt(MessageBusState.lastId, 10)
    var version = $(this).data('version')
    var channel = ['/integration', gid, version].join('/')

    if (lastId >= 0) {
      console.debug('MessageBus subscribing to %s starting from %s', channel, lastId)
    } else {
      return false
    }

    if (window.location.search.match('last_id=')) {
      $.flash.notice('OpenID Connect Issuer verification in progress')

      window.addEventListener('beforeunload', unloadWarning)
    }

    MessageBus.start()

    console.debug('MessageBus %s %s', MessageBus.clientId, MessageBus.status())

    // TODO: show message that verification is in progress

    MessageBus.subscribe(channel, function (payload) {
      console.debug('MessageBus received payload: ', payload)
      var success = payload.success
      var error = payload.exception_object

      window.removeEventListener('beforeunload', unloadWarning)

      if (success) {
        $.flash.notice('OpenID Connect Issuer valid')
      } else if (error) {
        $.flash.error('OpenID Connect: ' + error, { text: true })
      }
    }, lastId)
  })
})
