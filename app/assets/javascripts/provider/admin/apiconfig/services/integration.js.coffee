#= require 'provider/admin/apiconfig/services/integration/oidc'

# TODO: refactor, separate, extract useful stuff
$(document).on 'initialize', '#proxy', ->
  toggledInputsInit()

  # tooltips
  $("input.error").tipsy
    trigger: "focus"

  # API TEST REQUEST ------------------------------------------------
  $("form.proxy").on "change keyup", 'input, select', ->
    if $("#proxy_api_test_path").val()
      $("#client-request").show()
      $("#proxy_api_test_path_input > .inline-hints").html """
         Optional GET request to a API gateway endpoint. We will use this call
         to validate your API gateway setup using credentials of the first live
         application. You can try it yourself by copying the following command
         into your shell:
      """
      el = $('#api-test-curl')
      el_production = $('#api-production-curl')
      proxy = $('#proxy_sandbox_endpoint').val()
      proxy_production = $('#proxy_hosted_proxy_endpoint').val()
      path = $('#proxy_api_test_path').val()
      extheaders = ' '

      # Fetch and translate auth parameter names: user_key => my_user_key
      credentials = {}
      for param,value of el.data('credentials')
        param_name = $("#proxy_auth_#{param}").val() || param
        credentials[param_name] = value

      # append auth parameters to URL or as headers
      if $("#proxy_credentials_location_input input:checked").val() == 'headers'
        for k,v of credentials
          extheaders +=  "-H '#{k}: #{v}' "
        query = ''
      else
        q = if path.match(/\?/) then '&' else '?'
        query = "#{q}#{$.param(credentials)}"
        extheaders = ''

      code = "curl \"#{proxy}#{path}#{query}\" #{extheaders}"
      el.html(code)

      code_production = "curl \"#{proxy_production}#{path}#{query}\" #{extheaders}"
      el_production.html (code_production)
    else
      $("#proxy_api_test_path_input > .inline-hints").html """
       Optional GET request to a API gateway endpoint. This call
       has been left blank and therefore it will not be possible to
       test if the connection between client, proxy & API is working
       correctly.
      """
      $(".feedback").addClass("no-test")
      $("#client-request").hide()
  # -----------------------------------------------------------------


  # PROXY RULES -----------------------------------------------------
  # deleting proxy rules
  $("input.destroyer[value=\"1\"]:not(:disabled)").closest("tr").addClass "deleted"

  # adding proxy rules
  $("a[href=\"#add-proxy-rule\"]").live "click", ->
    rule = $("#new-proxy-rule-template").html()
    timestamp = new Date().getTime()
    rule = rule.replace(/\{new_id_.*\}/g, timestamp)
    rule = $("<tr>").append(rule)
    rule.find("input:not(.destroyer),select").removeAttr "disabled"
    $("table#proxy-rules > tbody").append rule
    rule.find('.pattern input:first').focus()
    false

  $("a[href=\"#delete-proxy-rule\"]").live "click", ->
    tr = $(this).closest("tr")
    if tr.hasClass("deleted")
      tr.removeClass "deleted"
      tr.find("input.proxy_rule_id, .destroyer").attr "disabled", "disabled"
    else
      tr.addClass "deleted"
      tr.find("input, select").attr "disabled", "disabled"
      tr.find("input.proxy_rule_id, .destroyer").removeAttr "disabled"
    tr.find("input").trigger "proxy.rule.change"
    false

  $("a[href=\"#edit-proxy-rule\"]").live "click", ->
    tr = $(this).closest("tr")
    tr.find("select,input:not(.destroyer)").removeAttr "disabled"  unless tr.hasClass("deleted")
    false
  #---------------------------------------------------------------------

  # REVERTING TO DEFAULTS (Proxy Endpoint and API host fields) ---------
  host_header_warning = $('<span class="warning-host-header" title="Your URL does not match the custom Host Header in Authentication Settings section"><i class="fa fa-exclamation-triangle"></i></span>')

  proxy_sandbox_endpoint = $('#proxy_sandbox_endpoint')
  if proxy_sandbox_endpoint.data('default')
    proxy_sandbox_endpoint.after '<span class="undo"><i class="fa fa-undo"></i> Use Default URL</span>'

  $('#proxy_api_backend')
    .after('<a href class="undo"><i class="fa fa-undo"></i> Use Echo API</a>')
    .after(host_header_warning)

  proxy_endpoint = $('#proxy_endpoint')
  if proxy_endpoint.data('default')
    proxy_endpoint.after('<span class="undo"><i class="fa fa-undo"></i> Use Default URL</span>')

  toggle_host_header_warning = ->
    host_header = $('#proxy_hostname_rewrite').val()
    api_backend = $('#proxy_api_backend').val()

    valid = host_header.length == 0 || extractHost(api_backend) == host_header
    host_header_warning.toggle(!valid)

  input_changed_from_default = (input) ->
    !compareHttpHosts( input.val(), input.data('default') )

  toggle_reset_buttons = ->
    $('form.proxy input[data-default]').each ->
      input = $(this)
      undo_button = input.siblings '.undo'
      undo_button.toggle( input_changed_from_default(input) )
      input.siblings('.inline-hints').find('span').toggle( input_changed_from_default(input) )

  reset_proxy_input = (event) ->
    input = $(this).siblings('input')
    input.val(input.data('default'))
    toggle_form_changed_ui()
    toggle_reset_buttons()
    toggle_host_header_warning()
    event.preventDefault()

  extractHost = (url) ->
    link = document.createElement('a')
    link.href = url
    link.hostname

  compareHttpHosts = (a, b) ->
    extractHost(a) == extractHost(b)

  extractHost = (url) ->
    link = document.createElement('a')
    link.href = url
    link.hostname

  compareHttpHosts = (a, b) ->
    extractHost(a) == extractHost(b)

  toggle_reset_buttons()
  toggle_host_header_warning()

  #---------------------------------------------------------------------


  # FORM CHANGE DETECTION ----------------------------------------------
  # saves status of the form on load
  form = $("form.staging-settings")
  form.data "old-settings", form.serialize()

  # displays 'pending changes' warning if necessary
  toggle_form_changed_ui = ->
    form = $("form.staging-settings")
    new_settings = form.serialize()
    old_settings = form.data("old-settings")
    $('#integration-tabs').toggleClass('changed',new_settings isnt old_settings)

    if new_settings is old_settings
      if not $("#proxy_api_test_path").val()
        $(".feedback-summary").html "The API test GET request has been left blank. You should set it before checking the connections between client, proxy & API."
      else
        $(".feedback-summary").html "Hit the test button to check the connections between client, gateway & API."
    else
      if not $("#proxy_api_test_path").val()
        $(".feedback-summary").html "The API test GET request has been left blank. You should set it before checking the connections between client, proxy & API."
      else
        $(".feedback-summary").html "Hit the test button to check the connections between client, gateway & API."
    toggle_reset_buttons()

  form.on "proxy.rule.change", toggle_form_changed_ui
  form.on "click", "input[type=\"radio\"]", toggle_form_changed_ui
  form.on('change keyup', '#proxy_hostname_rewrite, #proxy_api_backend', toggle_host_header_warning)

  form = $("form.proxy")
  form.on "change keyup", "input, select", toggle_form_changed_ui
  form.on "click", ".undo", reset_proxy_input

  #---------------------------------------------------------------------

  $("a[href=\"#traffic-check-trigger\"]").click ->
    $("#traffic-check-widget .charts").trigger "chart:reload"
    false

  proxy_credentials_location_value = $('input[name="proxy[credentials_location]"]:checked').val()

  replace_hyphens_or_underscores = (elt) ->
    return unless elt
    elt.value = switch proxy_credentials_location_value
      when 'headers' then elt.value.replace(/_/g,'-')
      when 'query' then elt.value.replace(/-/g,'_')

  $(document).on 'change', 'input[name="proxy[credentials_location]"]', (event) ->
    proxy_credentials_location_value = this.value
    replace_hyphens_or_underscores(document.getElementById('proxy_auth_user_key'))
    toggle_form_changed_ui()

  $(document).on 'input', 'input#proxy_auth_user_key', (event) ->
    replace_hyphens_or_underscores(this)

$ ->
  $('#proxy').trigger('initialize')
