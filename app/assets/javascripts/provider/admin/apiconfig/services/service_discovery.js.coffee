$ ->
  form = $('form#new_service,form#create_service')[0]

  change_service_source = (e)->
    $(form.namespace).find('option').not(':first').remove()
    if form.source.value == 'discover'
      form.namespace.removeAttribute('disabled')
      $(form.service_name).replaceWith('<select name="service[name]" id="service_name"><option/></select>')
      form.service_system_name.setAttribute('readonly', true)
      $.getJSON '/p/admin/service_discovery/projects.json', (data)->
        data.projects.forEach (project, index, array) ->
          namespace = project.metadata.name
          $(form.namespace).append("<option value=\"#{namespace}\">#{namespace}</option>")
        if data.projects.length > 0
          form.namespace.selectedIndex = 1
          change_cluster_namespace()
    else
      form.namespace.setAttribute('disabled', 'disabled')
      $(form.service_name).replaceWith('<input type="text" name="service[name]" id="service_name" maxlength="255"/>')
      form.service_system_name.removeAttribute('readonly')
      form.service_system_name.value = ''

  change_cluster_namespace = (e)->
    $(form.service_name).find('option').not(':first').remove()
    form.service_system_name.value = ''
    selected_namespace = $(form.namespace).find('option:checked').val()
    if selected_namespace != ''
      $.getJSON "/p/admin/service_discovery/namespaces/#{selected_namespace}/services.json", (data)->
        data.services.forEach (service, index, array) ->
          metadata = service.metadata
          $(form.service_name).append("<option value=\"#{metadata.name}\">#{metadata.name}</option>")
        if data.services.length > 0
          form.service_name.selectedIndex = 1
          change_cluster_service()
    else
      form.service_system_name.value = ''

  change_cluster_service = (e)->
    if form.service_name.value != ''
      form.service_system_name.value = "#{form.namespace.value}-#{form.service_name.value}"
    else
      form.service_system_name.value = ''

  unless typeof form == 'undefined'
    $(form.source).click change_service_source
    $(form.namespace).live 'change', change_cluster_namespace
    $(form).on 'change', "select[name='service[name]']", change_cluster_service
