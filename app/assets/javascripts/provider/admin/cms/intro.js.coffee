create_glower = (trigger, selector) ->
  $(trigger).hover -> $(selector).toggleClass('glowing')

create_intro_tabs = () ->
  tab_ids = []
  for page, i in $('#cms-intro-tabs div.cms-intro-page')
    id = $(page).attr('id')
    title = $(page).data('title')
    tab_ids.push(id)
    $(page).data('ui-tabs-index', i)
    $('#cms-intro-tabs > ul').append("<li><a href='##{id}'>#{title}</a></li>")

  hashLocationString = window.location.hash.replace('#', '')
  if $.inArray(hashLocationString, tab_ids) >= 0
    tab = hashLocationString
  else if $.inArray($.cookie('getting-started-tabs'), tab_ids) >= 0
    tab = $.cookie('getting-started-tabs')
  else
    tab = tab_ids[0]

  try
    $('#cms-intro-tabs').tabs
      active: $("#cms-intro-tabs > ##{tab}").data('ui-tabs-index')
      activate: (event,ui) -> 
        currentTab = ui.newPanel.selector.slice(1)
        $.cookie('getting-started-tabs', currentTab)
        window.setLocationHash(currentTab)

  catch err
    console.log "#{tab} isn't a valid css selector"



$(document).ready ->
  if $('#cms-intro-tabs').length > 0
    create_glower "#filter-glow", "#cms-filter input"
    create_glower "#type-glow", "#cms-sidebar-filter-type li"
    create_glower "#origin-glow", "#cms-sidebar-filter-origin li"
    create_glower "#partials-glow", '#cms-sidebar-filter-type li[data-filter-type="partial"]'
    create_glower "#layouts-glow", '#cms-sidebar-filter-type li[data-filter-type="layout"]'

    create_intro_tabs()
