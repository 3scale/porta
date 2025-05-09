class Api::TermsController < FrontendController

  activate_menu :site
  before_action :find_service

  def default
    @service = current_user.accessible_services.default
    redirect_to :action => :edit, :service_id => @service.id
  end

  def edit
  end

  def update
    if @edited_service.update(params[:edited_service])
      redirect_to edit_admin_service_terms_path(@edited_service), success: 'Terms & Conditions updated.'
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
