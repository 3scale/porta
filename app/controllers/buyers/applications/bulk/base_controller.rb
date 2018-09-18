class Buyers::Applications::Bulk::BaseController < FrontendController
  before_action :authorize_bulk_operations
  before_action :find_applications

  protected

  def authorize_bulk_operations
    authorize! :manage, :applications
  end

  def find_applications
    @applications = collection
  end

  def collection
    current_account.provided_cinstances.where(id: params[:selected]).includes(:user_account)
  end

  def handle_errors
    if @errors.present?
      render 'buyers/applications/bulk/shared/errors.html', :status => :unprocessable_entity
    end
  end
end
