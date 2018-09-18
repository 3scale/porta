class Provider::Admin::GoLiveStatesController < FrontendController

  def show
    respond_to :js
  end

  def update
    current_account.go_live_state.close!()
    if request.xhr?
      render json: {status: :ok}
    else
      redirect_to provider_admin_dashboard_path
    end
  end
end
