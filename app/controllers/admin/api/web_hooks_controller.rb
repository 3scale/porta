class Admin::Api::WebHooksController < Admin::Api::BaseController

  clear_respond_to
  respond_to :json

  wrap_parameters ::WebHook

  # WebHooks Update
  # PUT /admin/api/webhooks.json
  def update
    webhook.update(webhook_params)
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
