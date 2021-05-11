# frozen_string_literal: true

class Api::ServicesController < Api::BaseController
  include ServiceDiscovery::ControllerMethods
  include SearchSupport
  include ThreeScale::Search::Helpers

  activate_menu :serviceadmin, :overview

  before_action :deny_on_premises_for_master
  before_action :authorize_section
  before_action :authorize_action, only: %i[new create]
  load_and_authorize_resource :service, through: :current_user, through_association: :accessible_services, except: [:create]

  with_options only: %i[edit update settings usage_rules] do |actions|
    actions.sublayout 'api/service'
  end

  def index
    activate_menu :products
    search = ThreeScale::Search.new(params[:search] || params)
    @services = current_user.accessible_services
                            .order(updated_at: :desc)
                            .scope_search(search)
    @page_services = @services.paginate(pagination_params)
                              .decorate
                              .to_json(only: %i[name updated_at id system_name], methods: %i[links apps_count backends_count unread_alerts_count])
  end

  def show
    @service = @service.decorate
  end

  def new
    activate_menu :products
    @service = ServicePresenter.new(collection.build(params[:service]))
  end

  def edit
    activate_menu :serviceadmin, :overview
  end

  def settings
    activate_menu :serviceadmin, :integration, :settings
    render :settings
  end

  def usage_rules
    activate_menu :serviceadmin, :applications, :usage_rules
  end

  def create
    @service = ServicePresenter.new(collection.new)
    creator = ServiceCreator.new(service: @service)

    if can_create? && creator.call(create_params)
      flash[:notice] = t('flash.services.create.notice', resource_type: 'Product')
      redirect_to admin_service_path(@service)
    else
      flash.now[:error] = @service.errors.full_messages.to_sentence.presence || I18n.t!('flash.services.create.errors.default', {resource_type: 'Product'})
      activate_menu :dashboard
      render :new
    end
  end

  def update
    if integration_settings_updater_service.call(service_attributes: service_params, proxy_attributes: proxy_params)
      flash[:notice] =  t('flash.services.update.notice', resource_type: 'Product')
      redirect_back_or_to :action => :settings
    else
      flash.now[:error] = t('flash.services.update.error', resource_type: 'Product')
      render action: params[:update_settings].present? ? :settings : :edit # edit page is only page with free form fields. other forms are less probable to have errors
    end
  end

  def destroy
    @service.mark_as_deleted!
    flash[:notice] = t('flash.services.destroy.notice', resource_type: 'Product', resource_name: @service.name)
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

  DEFAULT_PARAMS = [
    { oidc_configuration_attributes: OIDCConfiguration::Config::FLOWS + [:id] },
    :oidc_issuer_type,
    :oidc_issuer_endpoint,
    :jwt_claim_with_client_id,
    :jwt_claim_with_client_id_type,
    :auth_user_key,
    :auth_app_id,
    :auth_app_key,
    :credentials_location,
    :hostname_rewrite,
    :secret_token,
    :error_status_auth_failed,
    :error_headers_auth_failed,
    :error_auth_failed,
    :error_status_auth_missing,
    :error_headers_auth_missing,
    :error_auth_missing,
    :error_status_no_match,
    :error_headers_no_match,
    :error_no_match,
    :error_status_limits_exceeded,
    :error_headers_limits_exceeded,
    :error_limits_exceeded
  ].freeze

  def proxy_params
    permitted_params = DEFAULT_PARAMS
    permitted_params += %i[endpoint sandbox_endpoint] if can_edit_endpoints?
    params.require(:service).fetch(:proxy_attributes, {}).permit(permitted_params)
  end

  def can_edit_endpoints?
    Rails.application.config.three_scale.apicast_custom_url || service.proxy.saas_configuration_driven_apicast_self_managed?
  end

  def collection
    current_user.accessible_services
  end

  def authorize_section
    authorize! :manage, :plans
  end

  def authorize_action
    return if current_user.admin? # We want to postpone for admins so we can use #can_create? and provide better error messages
    authorize! action_name.to_sym, Service
  end

  def can_create?
    can? :create, Service
  end
end
