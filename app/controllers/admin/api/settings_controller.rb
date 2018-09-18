class Admin::Api::SettingsController < Admin::Api::BaseController

  clear_respond_to
  respond_to :json

  wrap_parameters ::Settings
  representer ::Settings

  ALLOWED_PARAMS = %i(
    useraccountarea_enabled hide_service signups_enabled account_approval_required strong_passwords_enabled
    public_search account_plans_ui_visible change_account_plan_permission service_plans_ui_visible
    change_service_plan_permission end_user_plans_ui_visible
  ).freeze

  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/settings.json"
  ##~ e.responseClass = "settings"
  #
  ##~ op = e.operations.add
  ##~ op.nickname   = "service_metric"
  ##~ op.httpMethod = "GET"
  ##~ op.summary    = "Settings Read"
  ##~ op.description = "Returns the general settings of an account."
  ##~ op.group = "settings"
  #
  ##~ op.parameters.add @parameter_access_token
  #
  def show
    respond_with(settings)
  end

  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/settings.json"
  ##~ e.responseClass = "settings"
  #
  ##~ op             = e.operations.add
  ##~ op.httpMethod  = "PUT"
  ##~ op.summary     = "Settings Update"
  ##~ op.description = "Updates general settings."
  ##~ op.group       = "settings"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add :name => "useraccountarea_enabled", :description => "Allow the user to edit their submitted details, change passwords, etc", :dataType => "boolean", :paramType => "query"
  ##~ op.parameters.add :name => "hide_service", :description => "Used a default service plan", :dataType => "boolean", :paramType => "query"
  ##~ op.parameters.add :name => "signups_enabled", :description => "Developers are allowed sign up themselves.", :dataType => "boolean", :paramType => "query"
  ##~ op.parameters.add :name => "account_approval_required", :description => "Approval is required by you before developer accounts are activated.", :dataType => "boolean", :paramType => "query"
  ##~ op.parameters.add :name => "strong_passwords_enabled", :description => "Require strong passwords from your users: Password must be at least 8 characters long, and contain both upper and lowercase letters, a digit and one special character of -+=><_$#.:;!?@&*()~][}{|. Existing passwords will still work. ", :dataType => "boolean", :paramType => "query"
  ##~ op.parameters.add :name => "public_search", :description => "Enables public search on Developer Portal", :dataType => "boolean", :paramType => "query"
  ##~ op.parameters.add :name => "account_plans_ui_visible", :description => "Enables visibility of Account Plans", :dataType => "boolean", :paramType => "query"
  ##~ op.parameters.add :name => "change_account_plan_permission", :description => "Account Plans changing", :dataType => "string", :paramType => "query"
  ##~ op.parameters.add :name => "service_plans_ui_visible", :description => "Enables visibility of Service Plans", :dataType => "boolean", :paramType => "query"
  ##~ op.parameters.add :name => "change_service_plan_permission", :description => "Service Plans changing", :dataType => "string", :paramType => "query"
  ##~ op.parameters.add :name => "end_user_plans_ui_visible", :description => "Enables visibility of End User Plans", :dataType => "boolean", :paramType => "query"
  def update
    settings.update_attributes(settings_params)
    respond_with(settings)
  end

  private

  def settings
    @settings ||= current_account.settings
  end

  def settings_params
    params.require(:settings).permit(*ALLOWED_PARAMS)
  end
end
