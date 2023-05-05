class Admin::Api::WebHooksFailuresController < Admin::Api::BaseController
  representer WebHookFailures

  before_action :authorize_web_hooks

  # Webhooks List Failed Deliveries
  # GET /admin/api/webhooks/failures.xml
  def show
    respond_with(failures)
  end

  # Webhooks Delete Failed Deliveries
  # DELETE /admin/api/webhooks/failures.xml
  def destroy
    if params[:time] && !WebHookFailures.valid_time?(params[:time])
      render_error 'invalid time', status: :bad_request
    else
      failures.delete(params[:time])
      respond_with(failures, head: :ok)
    end
  end

  private

  def authorize_web_hooks
    authorize!(:manage, :web_hooks) if current_user
  end

  def failures
    @failures ||= WebHookFailures.new(current_account.id)
  end

end
