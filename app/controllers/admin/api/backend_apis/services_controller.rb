# frozen_string_literal: true

class Admin::Api::BackendApis::ServicesController < Admin::Api::BackendApis::BaseController
  wrap_parameters Service, include: Service.attribute_names | %w[state_event]
  representer Service

  # TODO: ActiveDocs
  # TODO: Refactor
  # TODO: should it all be called product instead of service?
  # TODO: paginate

  def index
    services = backend_api.services.accessible
    respond_with(services)
  end

  def create
    service = current_account.services.build
    create_service = ServiceCreator.new(service: service, backend_api: backend_api)
    create_service.call(service_params)
    service.reload if service.persisted? # It has been touched # TODO: Add test for this
    respond_with(service)
  end

  def show
    respond_with(service)
  end

  def update
    service.update(service_params)
    respond_with(service)
  end

  def destroy
    service.mark_as_deleted
    respond_with(service)
  end

  private

  def service
    @service ||= backend_api.services.accessible.find(params[:id])
  end

  def service_params
    permitted_params = [:name, :system_name, :description, :support_email, :deployment_option, :backend_version,
                        :intentions_required, :buyers_manage_apps, :referrer_filters_required,
                        :buyer_can_select_plan, :buyer_plan_change_permission, :buyers_manage_keys,
                        :buyer_key_regenerate_enabled, :mandatory_app_key, :custom_keys_enabled, :state_event,
                        :txt_support, :terms,
                        {notification_settings: [web_provider: [], email_provider: [], web_buyer: [], email_buyer: []]}]
    params.require(:service).permit(*permitted_params)
  end
end
