$ ->

  $('#close-widget-button').click (event) ->
    event.preventDefault()
    $.ajax
      url: $(@).attr('href')
      type: 'PUT'
    $('#launch-widget').addClass('hide')
    $('#quick-nav-widget').removeClass('hide')
