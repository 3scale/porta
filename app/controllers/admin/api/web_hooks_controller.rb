class Admin::Api::WebHooksController < Admin::Api::BaseController

  clear_respond_to
  respond_to :json

  wrap_parameters ::WebHook

  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/webhooks.json"
  ##~ e.responseClass = "webhook"
  #
  ##~ op             = e.operations.add
  ##~ op.httpMethod  = "PUT"
  ##~ op.summary     = "WebHooks Update"
  ##~ op.description = "Updates webhooks."
  ##~ op.group       = "webhook"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add :name => "url", :description => "URL that will be notified about all the events", :dataType => "string", :paramType => "query"
  ##~ op.parameters.add :name => "active", :description => "Activate/Disable WebHooks", :dataType => "boolean", :paramType => "query"
  ##~ op.parameters.add :name => "provider_actions", :description => "Dashboard actions fire webhooks. If false, only user actions in the portal trigger events.", :dataType => "boolean", :paramType => "query"
  ##~ op.parameters.add :name => "account_created_on", :dataType => "boolean", :paramType => "query"
  ##~ op.parameters.add :name => "account_updated_on", :dataType => "boolean", :paramType => "query"
  ##~ op.parameters.add :name => "account_deleted_on", :dataType => "boolean", :paramType => "query"
  ##~ op.parameters.add :name => "user_created_on", :dataType => "boolean", :paramType => "query"
  ##~ op.parameters.add :name => "user_updated_on", :dataType => "boolean", :paramType => "query"
  ##~ op.parameters.add :name => "user_deleted_on", :dataType => "boolean", :paramType => "query"
  ##~ op.parameters.add :name => "application_created_on", :dataType => "boolean", :paramType => "query"
  ##~ op.parameters.add :name => "application_updated_on", :dataType => "boolean", :paramType => "query"
  ##~ op.parameters.add :name => "application_deleted_on", :dataType => "boolean", :paramType => "query"
  ##~ op.parameters.add :name => "account_plan_changed_on", :dataType => "boolean", :paramType => "query"
  ##~ op.parameters.add :name => "application_plan_changed_on", :dataType => "boolean", :paramType => "query"
  ##~ op.parameters.add :name => "application_user_key_updated_on", :dataType => "boolean", :paramType => "query"
  ##~ op.parameters.add :name => "application_key_created_on", :dataType => "boolean", :paramType => "query"
  ##~ op.parameters.add :name => "application_key_deleted_on", :dataType => "boolean", :paramType => "query"
  ##~ op.parameters.add :name => "application_suspended_on", :dataType => "boolean", :paramType => "query"
  ##~ op.parameters.add :name => "application_key_updated_on", :dataType => "boolean", :paramType => "query"
  def update
    webhook.update_attributes(webhook_params)
    respond_with(webhook)
  end

  private

  def webhook
    @webhook ||= current_account.web_hook || current_account.build_web_hook
  end

  def allowed_params
    %w(url active provider_actions) + WebHook.switchable_attributes
  end

  def webhook_params
    params.fetch(:web_hook).permit(*allowed_params)
  end
end
