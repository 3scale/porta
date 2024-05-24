/* eslint-disable */
// @ts-nocheck
import $ from 'jquery'

// This is missing $.cookie, but it's been broken since cms_toolbar_v2 so it's not worth it anymore.

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
    return
    $.cookie('cms-toolbar-state', {
      path: '/'
    })
  }
  const saveToolbarState = state => {
    return
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
