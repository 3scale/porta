class Api::SupportsController < FrontendController

  activate_menu :serviceadmin
  before_action :find_service

  def edit
  end

  def update
    if @edited_service.update_attributes(params[:service])
      flash[:notice] =  'Support information was updated.'
      redirect_to edit_admin_service_support_path(@service)
    else
      render :action => :edit
    end
  end

  protected

  def find_service
    @edited_service = current_user.accessible_services.find params[:service_id]
    authorize! :update, @edited_service
    authorize! :manage, :connect_portal
  end

end
