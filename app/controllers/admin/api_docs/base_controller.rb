# frozen_string_literal: true

class Admin::ApiDocs::BaseController < FrontendController
  before_action :find_api_docs, only: %i[destroy edit update show preview toggle_visible]
  before_action :deny_on_premises_for_master



  def preview
    if api_docs_service.specification.swagger?
      respond_to do |format|
        format.html { render 'swagger' }
        format.json { render json: swagger_spec }
      end
    else
      @host = current_account.domain
      @resource = api_docs_service.system_name
      @spec = ApiDocs::Service.spec_for api_docs_service
      render 'active_docs'
    end
  end

  def toggle_visible
    api_docs_service.toggle! :published

    message = api_docs_service.published? ? 'published' : 'unpublished'
    redirect_to preview_admin_api_docs_service_path(api_docs_service), notice: "Spec #{api_docs_service.name} #{message}"
  end

  def show
    specification = api_docs_service.specification
    if specification.swagger_2_0?
      # TODO: this is temporary until we get swagger-ui to load swagger-2.0
      response.headers['X-Frame-Options'] = 'SAMEORIGIN'
      json = JSON.pretty_generate specification.as_json
    else
      translator = ThreeScale::Swagger::Translator.translate! @api_docs_service.body
      json = translator.as_json
    end

    respond_to do | format |
      format.json { render json: json }
    end
  end

  def new
    @api_docs_service = current_scope.api_docs_services.new
  end

  def edit; end

  def update
    respond_to do |format|
      if api_docs_service.update(api_docs_params, without_protection: true)
        message = 'ActiveDocs Spec was successfully updated.'
        format.html { redirect_to(preview_admin_api_docs_service_path(api_docs_service), notice: message) }
        format.js { render js: "jQuery.flash.notice('#{message}')" }
      else
        format.html { render :edit }
        format.js {}
      end
    end
  end

  def index
    @api_docs_services = current_scope.api_docs_services.page(params[:page]).includes(:service)
  end

  def create
    @api_docs_service = current_scope.api_docs_services.new(api_docs_params(:system_name), without_protection: true)
    if @api_docs_service.save
      redirect_to(preview_admin_api_docs_service_path(@api_docs_service), notice: 'ActiveDocs Spec was successfully saved.')
    else
      render :new
    end
  end

  def destroy
    api_docs_service.destroy
    redirect_to admin_api_docs_services_path, notice: 'ActiveDocs Spec was successfully deleted.'
  end

  private

  attr_reader :api_docs_service

  def current_scope
    raise NoMethodError, "#{__method__} not implemented in #{self.class}"
  end

  def api_docs_params(*extra_params)
    permit_params = %i[name body description published skip_swagger_validations service_id] + extra_params
    params.require(:api_docs_service).permit(*permit_params)
  end

  def find_api_docs
    @api_docs_service = current_scope.api_docs_services.find_by_id_or_system_name!(params[:id])
  end

  def swagger_spec
    specification = api_docs_service.specification
    specification.swagger_2_0? ? specification : resource_listing
  end

  def resource_listing
    {
      swaggerVersion: '1.2',
      apis: [
        {
          description: api_docs_service.description || api_docs_service.name,
          path: "#{admin_api_docs_service_path(api_docs_service.system_name)}.{format}"
        }
      ],
      basePath: "#{request.protocol}#{request_target_host}"
    }
  end
end
