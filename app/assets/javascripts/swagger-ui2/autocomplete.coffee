# this is a ripoff active-docs/classes/messenger.js
# and is a replacement of swagger-ui/extensions.coffee for swagger-ui2.
class ThreeScaleAutoComplete
  constructor: ->
    @currentTip = null
    @currentField = null

    $(document).on "click", "div.apidocs-signin-message a", (event)=>
      window.location = ThreeScaleAutoComplete.Config.login_url
      false

    $(document).on "click", "#swagger-ui-container", (event)=>
      if(@currentTip isnt null and !$(event.target).is("input,select"))
        @currentTip.hide()

    $(document).on "click", ".apidocs-param-tips li", (event)=>
      @currentField.val($(event.currentTarget).attr('data-value'))
      @currentTip.hide()

    $(document).on "focus", "input[type=text]", (event)=>
      @currentTip.hide() if @currentTip isnt null

    $(document).on "focus","input[data-threescale-name]", (event)=>
      @currentField = $(event.currentTarget)
      type = @currentField.attr("data-threescale-name")
      return false if $.trim(type) is ""
      @currentTip = if +ThreeScaleAutoComplete.DataStatus is 401 then $(".apidocs-param-tips.apidocs-signin-message") else $(".apidocs-param-tips."+type)
      pos = @getPosition()
      @currentTip.css({top:pos[0], left:pos[1]}).fadeIn("fast")
      false

  getPosition: ->
    pos = @currentField.offset()
    [pos.top - 50, pos.left + @currentField.width() + 10]

ThreeScaleAutoComplete.init= (account_type)->
  $.getJSON ThreeScaleAutoComplete.Config.data_url[account_type], ThreeScaleAutoComplete.handleData

ThreeScaleAutoComplete.handleData = (data)->
  ThreeScaleAutoComplete.DataStatus = data.status
  if(+data.status == 200)
    template = Handlebars.compile(ThreeScaleAutoComplete.TipTemplate)
    html = _.reduce(data.results
      , (memo, values, key)->
          values = {type: key, items: values, description: ThreeScaleAutoComplete.TipDescriptions[key]}
          memo + template(values)
      , "")
    $("body").append(html)
  new ThreeScaleAutoComplete()

ThreeScaleAutoComplete.Config =
    data_url: {
      provider:"/p/admin/api_docs/account_data.json",
      buyer: "/api_docs/account_data.json"
    },
    login_url:  "/api_docs/login"

ThreeScaleAutoComplete.TipDescriptions =
  metric_names: "Latest 5 metrics"
  metric_ids: "Latest 5 metrics"
  app_keys: "First application key from the latest five applications"
  app_ids: "Latest 5 applications (across all accounts and services)"
  application_ids: "Latest 5 applications"
  user_keys: "First user key from latest 5 applications"
  account_ids: 'Latest 5 accounts'
  access_token: 'Access Token'
  user_ids: 'First user (admin) of the latest 5 account'
  service_ids: 'Latest 5 services'
  admin_ids: 'Latest 5 users (admin) from your account'
  service_plan_ids: 'Latest 5 service plans'
  application_plan_ids: 'Latest 5 application plans'
  account_plan_ids: 'Latest 5 account plans'
  client_ids: 'Client IDs from the latest five applications'
  client_secrets: 'Client secrets from the latest five applications'

ThreeScaleAutoComplete.DataStatus = 401

ThreeScaleAutoComplete.TipTemplate =
  """
  <div class='apidocs-param-tips {{type}}' style='display:none;'>
    <p class='apidocs-tip-description'>{{this.description}}</p>
    <ul>
      {{#each items}}
        <li data-value='{{value}}'><strong>{{name}}</strong> <span>{{value}}</span></li>
      {{/each}}
    </ul>
  </div>
  """

# Extends SwaggerUi to load 3scale extensions
swagger_ui_load = SwaggerUi::load
class ThreeScaleSwaggerUi
  constructor: (swagger_ui_load) ->
    @swagger_ui_load = swagger_ui_load

  load: (account_type)->
    ThreeScaleAutoComplete.init(account_type || "buyer")
    swagger_ui_load.apply @swagger_ui_load

SwaggerUi.prototype.load = (account_type)->
  new ThreeScaleSwaggerUi(this).load(account_type)

