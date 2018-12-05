class CreateApplication

  constructor: () ->
    @check_selected_plan()
    @previews_service

  metadata: ->
    $('#metadata-form')


  service_plans_names: ->
    @metadata().data('service_plans_names')

  services_contracted: ->
    @metadata().data('services_contracted')

  relation_service_and_service_plans: ->
    @metadata().data('relation_service_and_service_plans')

  relation_plans_services: ->
    @metadata().data('relation_plans_services')

  service_plan_contracted_for_service: ->
    @metadata().data('service_plan_contracted_for_service')

  selected_plan: ->
    $("#cinstance_plan_id").val()

  service_of_selected_plan: ->
    @relation_plans_services()[@selected_plan()]

  check_selected_plan: ->
    service = @service_of_selected_plan()
    service_plans = @relation_service_and_service_plans()[service]
    if @previews_service != service
      @disable_form(false)
      @previews_service = service
      if $.inArray(service, @services_contracted()) != -1
        service_plan_contracted = @service_plan_contracted_for_service()[service]

        $("#cinstance_service_plan_id").html("<option value='#{service_plan_contracted.id}'> #{service_plan_contracted.name } </option>")
        $("#cinstance_service_plan_id").attr('disabled', 'disabled')

      else if service_plans.length != 0
        @update_combo(service_plans)
      else
        $("#cinstance_service_plan_id").html("<option> No service plan for the application plan </option>")
        @disable_form(true)

  disable_form: (disable) ->
    $('#link-help-new-application-service').toggle(disable)
    @disable_field('#submit-new-app', disable)
    @disable_field('#cinstance_service_plan_id', disable)

  disable_field: (field, disable) ->
    if disable
      $(field).attr('disabled', 'disabled')
    else
      $(field).removeAttr('disabled')


  update_combo: (service_plans) ->
    options = ""
    $(service_plans).each (index, service_plan) ->
      selected_attr = if service_plan.default then 'selected="selected"' else ''
      options += "<option value='#{service_plan.id}' #{selected_attr}>#{service_plan.name}</option>"

    $("#cinstance_service_plan_id").html(options)
    $("#cinstance_service_plan_id").removeAttr('disabled')



$(document).ready ->
  window.createApplication = new CreateApplication()
