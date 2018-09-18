class Admin::Api::WebHooksFailuresController < Admin::Api::BaseController
  representer WebHookFailures

  before_action :authorize_web_hooks

  # swagger
  ##~ sapi = source2swagger.namespace("Account Management API")
  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/webhooks/failures.xml"
  ##~ e.responseClass = "List[webhook_failures]"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "GET"
  ##~ op.summary    = "Webhooks List Failed Deliveries"
  ##~ op.description = "Lists of webhooks that could not be delivered to your end-point after 5 trials. A webhook is considered delivered if your end-point responds with a 200, otherwise it retries 5 times at 60 second intervals."
  ##~ op.group = "webhooks"
  #
  ##~ op.parameters.add @parameter_access_token
  #
  def show
    respond_with(failures)
  end

  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "DELETE"
  ##~ op.summary    = "Webhooks Delete Failed Deliveries"
  ##~ op.description = "Deletes failed delivery records. It is advisible to delete the records past the time of the last webhook failure that was received instead of deleting them all. Between the GET and the DELETE other webhooks failures may have arrived."
  ##~ op.group = "webhooks"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add :name => "time", :description => "Only failed webhook deliveries whose time is less than or equal to the passed time are destroyed (if used).", :dataType => "time", :required => false, :paramType => "query"
  #
  def destroy
    if params[:time] && !WebHookFailures.valid_time?(params[:time])
      render_error 'invalid time', status: :bad_request
    else
      failures.delete(params[:time])
      respond_with(failures, nothing: true)
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
