class Buyers::Accounts::Bulk::BaseController < FrontendController

  before_action :authorize_bulk_operations
  before_action :find_accounts

  protected

  def authorize_bulk_operations
    authorize! :manage, :partners
  end

  def find_accounts
    @accounts = collection
  end

  def collection
    current_account.buyers.where(id: params[:selected])
  end

  def handle_errors
    if @errors.present?
      render 'buyers/accounts/bulk/shared/errors', :status => :unprocessable_entity, formats: [:html]
    end
  end
end
