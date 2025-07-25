# frozen_string_literal: true

class Admin::ApiDocs::BaseController < FrontendController
  before_action :deny_on_premises_for_master
  before_action :authorize_api_docs
  before_action :find_api_docs, only: %i[show preview toggle_visible edit update destroy]
  before_action :new_service_id_permitted, only: %i[create update]
  helper_method :current_scope

  def index
    @presenter = Provider::Admin::ApiDocsIndexPresenter.new(scope: current_scope,
                                                            user: current_user,
                                                            params: params)
  end

  def new
    @api_docs_service = api_docs_services.new
  end

  def create
    @api_docs_service = api_docs_services.new(api_docs_params(:system_name), without_protection: true)
    if @api_docs_service.save
      redirect_to preview_admin_api_docs_service_path(@api_docs_service), success: t('admin.api_docs.create.success')
    else
      render :new
    end
  end

  # Fetching the spec JSON via /admin/api_docs/services/<ID>.json
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

  # Render the spec preview page, e.g. /apiconfig/services/<svc_id>/api_docs/<api_doc_id>/preview
  def preview
    if api_docs_service.specification.swagger?
      respond_to do |format|
        format.html { render 'swagger' }
        format.json { render json: swagger_spec }
      end
    else
      @host = current_account.external_domain
      @resource = api_docs_service.system_name
      @spec = ApiDocs::Service.spec_for api_docs_service
      render 'active_docs'
    end
  end

  def toggle_visible
    api_docs_service.toggle! :published

    flash[:success] = t("admin.api_docs.base.toggle_visible.#{api_docs_service.published? ? :visible : :hidden}", name: api_docs_service.name)

    respond_to do |format|
      format.html { redirect_to preview_admin_api_docs_service_path(api_docs_service) }
    end
  end

  def edit; end

  def update
    respond_to do |format|
      if api_docs_service.update(api_docs_params, without_protection: true)
        msg = t('admin.api_docs.update.success')
        format.html { redirect_to preview_admin_api_docs_service_path(api_docs_service), success: msg }
        format.js do
          flash.now[:success] = msg
          render 'shared/flash_alerts'
        end
      else
        format.html { render :edit }
        format.js {}
      end
    end
  end

  def destroy
    api_docs_service.destroy

    flash[:success] = t('admin.api_docs.destroy.success')

    respond_to do |format|
      format.html { redirect_to admin_api_docs_services_path }
    end
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

  def api_docs_services
    current_scope.api_docs_services
  end

  def accessible_api_docs_services
    api_docs_services.permitted_for(current_user)
  end

  def find_api_docs
    @api_docs_service = accessible_api_docs_services.find_by_id_or_system_name!(params[:id])
  end

  def new_service_id_permitted
    service_id = api_docs_params[:service_id]
    service_id.blank? || current_user.accessible_services.find(service_id)
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
      basePath: "#{request.protocol}#{request.host_with_port}"
    }
  end

  def authorize_api_docs
    authorize! :manage, :plans
  end
end
