// = require 'vendor/jquery-3.5.0.min.js'
// = require 'vendor/jquery/extensions/jquery.cookie.js'

$(function () {
  const toolbar = $('#cms-toolbar')
  const iframe = $('#developer-portal')
  const toolbarMode = $('form#cms-toolbar-mode')
  toolbarMode.find('li').on('click', function () {
    $(this).closest('li').find('input').attr('checked', true)
    $(toolbarMode).trigger('change')
  })
  toolbarMode.on('change', () => {
    window.location = $(this).find('input:checked').val()
  })
  const enableAnimation = () => {
    toolbar.addClass('animate')
    iframe.addClass('animate')
  }
  const toggleValues = () => {
    toolbar.toggleClass('not-hidden')
    iframe.toggleClass('not-full')
  }
  const storedToolbarState = () => {
    $.cookie('cms-toolbar-state', {
      path: '/'
    })
  }
  const saveToolbarState = state => {
    $.cookie('cms-toolbar-state', state, {
      expires: 30,
      path: '/'
    })
  }
  iframe.on('load', () => {
    if (storedToolbarState() !== 'hidden') {
      toggleValues()
      return (window.requestAnimationFrame || window.setTimeout)(enableAnimation)
    } else {
      return enableAnimation()
    }
  })
  $('#hide-side-bar').on('click', event => {
    event.preventDefault()
    toggleValues()
    if (storedToolbarState() === 'hidden') {
      saveToolbarState('visible')
    } else {
      saveToolbarState('hidden')
    }
  })
})
