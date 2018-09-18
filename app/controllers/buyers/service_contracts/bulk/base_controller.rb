class Buyers::ServiceContracts::Bulk::BaseController < FrontendController
  before_action :authorize_bulk_operations
  before_action :find_service_contracts

  protected

  def authorize_bulk_operations
    authorize! :manage, :service_contracts
  end

  def find_service_contracts
    @service_contracts = collection
  end

  def collection
    current_account.provided_service_contracts.where(id: params[:selected])
  end

  def handle_errors
    if @errors.present?
      render 'buyers/applications/bulk/shared/errors.html', :status => :unprocessable_entity
    end
  end
end
