class Api::ContentsController < FrontendController

  activate_menu :serviceadmin
  before_action :find_service

  def edit
  end

  def update
    if @service.update_attributes(params[:service])
      flash[:notice] =  'Content updated.'
      redirect_to edit_admin_service_content_path(@service)
    else
      render :action => :edit
    end
  end

  protected

  def find_service
    @service = current_user.accessible_services.find params[:service_id]

    authorize! :update, @service
  end
end
