class Admin::ApiDocs::ServicesController < FrontendController
  before_action :find_service, :only => [:destroy, :edit, :update, :show, :preview, :toggle_visible]
  before_action :find_service_apis_collection, only: %i[new edit update]
  before_action :deny_on_premises_for_master

  activate_menu :active_docs, :submenu => :active_docs

  def preview
    if @api_docs_service.specification.swagger?
      respond_to do |format|
        format.html { render 'swagger' }
        format.json { render json: swagger_spec }
      end
    else
      @host = current_account.domain
      @resource = @api_docs_service.system_name
      @spec = ApiDocs::Service.spec_for @api_docs_service
      render 'active_docs'
    end
  end

  def toggle_visible
    @api_docs_service.toggle! :published

    message = if @api_docs_service.published?
      "published"
              else
      "unpublished"
              end

    redirect_to preview_admin_api_docs_service_path(@api_docs_service), notice: "Spec #{@api_docs_service.name} #{message}"
  end

  def show
    if @api_docs_service.specification.swagger_2_0?
      # TODO: this is temporary until we get swagger-ui to load swagger-2.0
      response.headers["X-Frame-Options"] = "SAMEORIGIN"
      json = JSON.pretty_generate @api_docs_service.specification.as_json
    else
      translator = ThreeScale::Swagger::Translator.translate! @api_docs_service.body
      json = translator.as_json
    end

    respond_to do | format |
      format.json { render json: json }
    end
  end

  def new
    @api_docs_service = current_account.api_docs_services.new
  end

  def edit; end

  def update
    respond_to do |format|
      if @api_docs_service.update(api_docs_params, without_protection: true)
        message = 'ActiveDocs Spec was successfully updated.'
        format.html { redirect_to(preview_admin_api_docs_service_path(@api_docs_service), notice: message) }
        format.js { render :js => "jQuery.flash.notice('#{message}')" }
      else
        flash[:error] = @api_docs_service.errors.full_messages.join(' ')
        format.html { render :edit }
        format.js {}
      end
    end
  end

  def index
    @api_docs_services = current_account.api_docs_services.page(params[:page])
  end

  def create
    @api_docs_service = current_account.api_docs_services.new(api_docs_params(:system_name), without_protection: true)
    respond_to do |format|
      if @api_docs_service.save
        format.html do
          redirect_to(preview_admin_api_docs_service_path(@api_docs_service), notice: 'ActiveDocs Spec was successfully saved.')
        end
      else
        flash[:error] = @api_docs_service.errors.full_messages.join(' ')
        format.html { render :new }
      end
    end
  end

  def destroy
    @api_docs_service.destroy

    respond_to do |format|
      format.html do
        redirect_to admin_api_docs_services_path, notice: 'ActiveDocs Spec was successfully deleted.'
      end
    end
  end

  private

  def api_docs_params(*extra_params)
    permit_params = %i[name body description published skip_swagger_validations service_id] + extra_params
    params.require(:api_docs_service).permit(*permit_params)
  end

  def find_service_apis_collection
    @service_apis = current_account.services.accessible
  end

  def find_service
    @api_docs_service = current_account.api_docs_services.find_by_id_or_system_name!(params[:id])
  end

  def swagger_spec
    if @api_docs_service.specification.swagger_2_0?
      @api_docs_service.specification
    else
      resource_listing
    end
  end

  def resource_listing
    {
      swaggerVersion: "1.2",
      apis: [
        {
          description: @api_docs_service.description.nil? ? @api_docs_service.name : @api_docs_service.description,
          path: "#{admin_api_docs_service_path(@api_docs_service.system_name)}.{format}"
        }
      ],
      basePath: "#{request.protocol}#{request_target_host}"
    }
  end
end
