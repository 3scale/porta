# frozen_string_literal: true

class Admin::Api::ServicesController < Admin::Api::ServiceBaseController
  include PermittedServiceSettings

  wrap_parameters Service, include: Service.attribute_names | %w[state_event annotations]
  representer Service

  before_action :deny_on_premises_for_master
  before_action :can_create, only: :create

  paginate only: :index

  # Service List
  # GET /admin/api/services.xml
  def index
    services = accessible_services.includes(:proxy, :annotations).order(:id).paginate(pagination_params)
    respond_with(services)
  end

  # Service Create
  # POST /admin/api/services.xml
  def create
    service = current_account.services.build
    create_service = ServiceCreator.new(service: service)
    create_service.call(service_params(service).to_h)
    service.reload if service.persisted? # It has been touched
    respond_with(service)
  end

  # Service Read
  # GET /admin/api/services/{id}.xml
  def show
    respond_with(service)
  end

  # Service Update
  # POST /admin/api/services/{id}.xml
  def update
    service.update(service_params.to_h)

    respond_with(service)
  end

  # Service Delete
  # DELETE /admin/api/services/{id}.xml
  def destroy
    authorize!(:destroy, service) if current_user
    service.mark_as_deleted!

    respond_with(service)
  end

  protected

  def can_create
    authorize!(:create, Service) if current_user
    head :forbidden unless current_account.can_create_service?
  end

  def service_params(service_record = service)
    permitted = params.require(:service).permit(*permitted_service_keys(service_record), annotations: {})
    filter_plan_change_permissions(permitted, :buyer_plan_change_permission)
  end

  def service
    @service ||= accessible_services.find(params[:id])
  end
end
