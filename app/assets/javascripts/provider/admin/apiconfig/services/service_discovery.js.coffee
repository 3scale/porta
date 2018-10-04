$ ->
  form_source = document.getElementById 'new_service_source'
  form_scratch = document.querySelectorAll('form#new_service,form#create_service')[0]
  form_discover = document.getElementById 'service_discovery'

  clear_select_options = (select)->
    options = select.getElementsByTagName('option')
    i = options.length - 1
    while i > 0
      options[i].remove()
      --i

  clear_namespaces = ()->
    clear_select_options form_discover.service_namespace

  clear_service_names = ()->
    clear_select_options form_discover.service_name

  show_service_form = (source, discover_func, scratch_func)->
    if source == 'discover'
      form_scratch.classList.add('is-hidden')
      form_discover.classList.remove('is-hidden')
      discover_func?()
    else
      form_scratch.classList.remove('is-hidden')
      form_discover.classList.add('is-hidden')
      scratch_func?()

  change_service_source = (e)->
    clear_namespaces()
    clear_service_names()
    show_service_form(form_source.source.value, fetch_namespaces)

  change_cluster_namespace = (e)->
    clear_service_names()
    selected_namespace = form_discover.service_namespace.value
    if selected_namespace != ''
      fetch_services(selected_namespace)

  fetch_namespaces = ()->
    $.getJSON '/p/admin/service_discovery/projects.json', (data)->
      projects = data.projects
      projects.forEach (project, index, array) ->
        namespace = project.metadata.name
        $(form_discover.service_namespace).append("<option value=\"#{namespace}\">#{namespace}</option>")
      if projects.length > 0
        form_discover.service_namespace.selectedIndex = 1
        change_cluster_namespace()

  fetch_services = (namespace)->
    $.getJSON "/p/admin/service_discovery/namespaces/#{namespace}/services.json", (data)->
      services = data.services
      services.forEach (service, index, array) ->
        service_name = service.metadata.name
        $(form_discover.service_name).append("<option value=\"#{service_name}\">#{service_name}</option>")
      if services.length > 0
        form_discover.service_name.selectedIndex = 1

  if form_source != null and typeof form_source != 'undefined'
    form_source.source.forEach (item) ->
      item.addEventListener 'click', change_service_source
      return

  if form_discover != null and typeof form_discover != 'undefined'
    form_discover.service_namespace.addEventListener 'change', change_cluster_namespace
