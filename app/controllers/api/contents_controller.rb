# frozen_string_literal: true

class Api::ContentsController < FrontendController

  activate_menu :serviceadmin
  before_action :find_service

  def edit; end

  def update
    if @service.update(params[:service])
      redirect_to edit_admin_service_content_path(@service), success: t('.success')
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
