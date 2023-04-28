# frozen_string_literal: true

class Admin::Api::ApiDocsServicesController < Admin::Api::BaseController
  before_action :deny_on_premises_for_master
  before_action :authorize_api_docs
  before_action :find_api_docs_service, only: %i[show update destroy]
  before_action :new_service_id_permitted, only: %i[create update]

  wrap_parameters ::ApiDocs::Service, name: :api_docs_service, include: ::ApiDocs::Service.attribute_names

  respond_to :json, :xml
  representer collection: ::ApiDocs::ServicesRepresenter, entity: ::ApiDocs::ServiceRepresenter


  # Disable CSRF protection for non xml requests.
  skip_before_action :verify_authenticity_token, if: -> do
    (params.key?(:provider_key) || params.key?(:access_token)) && request.format.json?
  end

  # ActiveDocs Spec List
  # GET /admin/api/active_docs.json
  def index
    @api_docs_services = api_docs_services.all
    respond_with(@api_docs_services)
  end

  # ActiveDocs Spec Create
  # POST /admin/api/active_docs.json
  def create
    @api_docs_service = current_account.api_docs_services.create(api_docs_params(:system_name), without_protection: true)
    respond_with(@api_docs_service)
  end

  # ActiveDocs Spec Read
  # GET /admin/api/active_docs/{id}.json
  def show
    respond_with(@api_docs_service)
  end

  # ActiveDocs Spec Update
  # PUT /admin/api/active_docs/{id}.json
  def update
    @api_docs_service.update(api_docs_params, without_protection: true)
    respond_with(@api_docs_service)
  end

  # ActiveDocs Spec Delete
  # DELETE /admin/api/active_docs/{id}.json
  def destroy
    @api_docs_service.destroy
    respond_with(@api_docs_service)
  end

  protected

  def api_docs_params(*extra_params)
    permit_params = %i[name body description published skip_swagger_validations service_id] + extra_params
    params.require(:api_docs_service).permit(*permit_params)
  end

  def api_docs_services
    current_account.api_docs_services.accessible.permitted_for(current_user)
  end

  def find_api_docs_service
    @api_docs_service = api_docs_services.find(params[:id])
  end

  def new_service_id_permitted
    service_id = api_docs_params[:service_id]
    service_id.blank? || current_user.blank? || current_user.accessible_services.find(service_id)
  rescue ActiveRecord::RecordNotFound
    render_error('Service not found', status: :unprocessable_entity)
  end

  def authorize_api_docs
    authorize! :manage, :plans if current_user
  end
end
