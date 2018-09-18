class Api::TransactionsController < FrontendController

  before_action :ensure_provider_domain
  activate_menu :monitoring, :traffic
  before_action :find_service

  skip_after_action :update_current_user_after_login

  def index
    @transactions = current_account.backend_object.latest_transactions

    render :partial => 'table_body' if request.xhr?
  end
end
