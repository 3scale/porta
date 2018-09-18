window.setLocationHash = (value) ->
  scroll = $('body').scrollTop()
  window.location.hash = value
  $('html,body').scrollTop(scroll)
