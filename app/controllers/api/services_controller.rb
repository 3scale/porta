# frozen_string_literal: true

class Api::ServicesController < Api::BaseController
  include ServiceDiscovery::ControllerMethods

  activate_menu :serviceadmin, :overview

  before_action :deny_on_premises_for_master
  before_action :authorize_manage_plans, only: %i[create destroy]
  before_action :authorize_admin_plans, except: %i[create destroy]

  load_and_authorize_resource :service, through: :current_user,
    through_association: :accessible_services, except: [:create]

  with_options only: %i[edit update settings usage_rules] do |actions|
    actions.sublayout 'api/service'
  end

  def show
    @service = @service.decorate
  end

  def new
    activate_menu :dashboard
    @service = ServicePresenter.new(collection.build(params[:service]))
  end

  def edit
    activate_menu :serviceadmin, :overview
  end

  def settings
    activate_menu :serviceadmin, :integration, :settings
    render settings_page
  end

  def usage_rules
    raise ActiveRecord::RecordNotFound unless apiap?
    activate_menu :serviceadmin, :applications, :usage_rules
  end

  def create
    @service = ServicePresenter.new(collection.new)
    creator = ServiceCreator.new(service: @service)

    if can_create? && creator.call(create_params)
      flash[:notice] = t('flash.services.create.notice', resource_type: product_or_service_type)
      onboarding.bubble_update('api')
      redirect_to admin_service_path(@service)
    else
      flash.now[:error] = @service.errors.full_messages.to_sentence.presence || I18n.t!('flash.services.create.errors.default', {resource_type: product_or_service_type})
      activate_menu :dashboard
      render :new
    end
  end

  def update
    if integration_settings_updater_service.call(service_attributes: service_params, proxy_attributes: proxy_params)
      flash[:notice] =  t('flash.services.update.notice', resource_type: product_or_service_type)
      onboarding.bubble_update('api') if service_name_changed?
      onboarding.bubble_update('deployment') if integration_method_changed? && !integration_method_self_managed?
      redirect_back_or_to :action => :settings
    else
      flash.now[:error] = t('flash.services.update.error', resource_type: product_or_service_type)
      render action: params[:update_settings].present? ? settings_page : :edit # edit page is only page with free form fields. other forms are less probable to have errors
    end
  end

  def destroy
    @service.mark_as_deleted!
    flash[:notice] = t('flash.services.destroy.notice', resource_type: product_or_service_type, resource_name: @service.name)
    redirect_to provider_admin_dashboard_path
  end

  private

  attr_reader :service

  def integration_settings_updater_service
    ApiIntegration::SettingsUpdaterService.new(service: service, proxy: service.proxy)
  end

  def create_params
    permitted_params = [:name, :system_name, :description, :support_email, :deployment_option, :backend_version,
                        :intentions_required, :buyers_manage_apps, :referrer_filters_required,
                        :buyer_can_select_plan, :buyer_plan_change_permission, :buyers_manage_keys,
                        :buyer_key_regenerate_enabled, :mandatory_app_key, :custom_keys_enabled, :state_event,
                        :txt_support, :terms, {proxy_attributes: Proxy.user_attribute_names},
                        {notification_settings: [web_provider: [], email_provider: [], web_buyer: [], email_buyer: []]}]
    params.require(:service).permit(permitted_params)
  end

  def service_params
    permitted_params = [:name, :system_name, :description, :support_email, :deployment_option, :backend_version,
                        :intentions_required, :buyers_manage_apps, :referrer_filters_required,
                        :buyer_can_select_plan, :buyer_plan_change_permission, :buyers_manage_keys,
                        :buyer_key_regenerate_enabled, :mandatory_app_key, :custom_keys_enabled, :state_event,
                        :txt_support, :terms,
                        {notification_settings: [web_provider: [], email_provider: [], web_buyer: [], email_buyer: []]}]
    params.require(:service).permit(permitted_params)
  end

  def proxy_params
    oidc_params = [:oidc_issuer_type, :oidc_issuer_endpoint, :jwt_claim_with_client_id, :jwt_claim_with_client_id_type, oidc_configuration_attributes: OIDCConfiguration::Config::FLOWS]
    permitted_params = oidc_params + %i[
      auth_user_key auth_app_id auth_app_key credentials_location hostname_rewrite secret_token
      error_status_auth_failed error_headers_auth_failed error_auth_failed
      error_status_auth_missing error_headers_auth_missing error_auth_missing
      error_status_no_match error_headers_no_match error_no_match
      error_status_limits_exceeded error_headers_limits_exceeded error_limits_exceeded
    ]
    permitted_params << :api_backend unless apiap?
    permitted_params += %i[endpoint sandbox_endpoint] if can_edit_endpoints?
    params.require(:service).fetch(:proxy_attributes, {}).permit(permitted_params)
  end

  def can_edit_endpoints?
    Rails.application.config.three_scale.apicast_custom_url || service.proxy.saas_configuration_driven_apicast_self_managed?
  end

  # This will be the default 'settings' when apiap is live
  def settings_page
    apiap? ? :settings_apiap : :settings
  end

  def product_or_service_type
    apiap? ? 'Product' : 'Service'
  end

  def service_name_changed?
    @service.previous_changes['name']
  end

  def integration_method_changed?
    @service.previous_changes['deployment_option']
  end

  def integration_method_self_managed?
    @service.proxy.self_managed?
  end

  def collection
    current_user.accessible_services
  end

  def can_create?
    can? :create, Service
  end

  def authorize_manage_plans
    authorize! :manage, :plans
  end

  def authorize_admin_plans
    authorize! :admin, :plans
  end
end
