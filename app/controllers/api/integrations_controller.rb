# frozen_string_literal: true

class Api::IntegrationsController < Api::BaseController
  before_action :find_service
  before_action :find_proxy
  before_action :authorize
  before_action :find_registry_policies, only: :update

  activate_menu :serviceadmin, :integration, :configuration
  sublayout 'api/service'

  PLUGIN_LANGUAGES = %w[ruby java python nodejs php rest csharp].freeze

  rescue_from ActiveRecord::StaleObjectError, with: :edit_stale

  def settings; end

  def update
    @show_presenter = Api::IntegrationsShowPresenter.new(@proxy)

    if @service.using_proxy_pro? && !@proxy.apicast_configuration_driven
      proxy_pro_update
    elsif @proxy.save_and_deploy(proxy_params)
      environment = @proxy.service_mesh_integration? ? 'Production' : 'Staging'
      flash[:notice] = flash_message(:update_success, environment: environment)
      update_mapping_rules_position

      redirect_to admin_service_integration_path(@service)
    else
      attrs = proxy_rules_attributes
      splitted = attrs.keys.group_by { |key| attrs[key]['_destroy'] == '1' }

      @marked_for_destroy = splitted[true]
      @marked_for_update = splitted[false]

      flash.now[:error] = flash_message(:update_error)
      @api_test_form_error = true

      render :show
    end
  end

  def promote_to_production
    if ProxyDeploymentService.call(@proxy, environment: :production)
      flash[:notice] = flash_message(:promote_to_production_success)
    else
      flash[:error] = flash_message(:promote_to_production_error)
    end
    redirect_to action: :show
  end

  def show
    @show_presenter = Api::IntegrationsShowPresenter.new(@proxy)
  end

  def toggle_apicast_version
    apicast_configuration_driven = @proxy.apicast_configuration_driven

    if @proxy.oidc? && apicast_configuration_driven
      flash[:error] = flash_message(:oidc_not_available_on_old_apicast)
    elsif @proxy.toggle!(:apicast_configuration_driven)
      apicast_configuration_driven_after_toggle = !apicast_configuration_driven

      analytics.track('APIcast Changed Version',
                      latest: apicast_configuration_driven_after_toggle,
                      service_id: @proxy.service_id,
                      deployment_option: @proxy.deployment_option
                     )
      flash[:success] = apicast_configuration_driven_after_toggle ? flash_message(:apicast_version_upgraded) : flash_message(:apicast_version_reverted)
    else
      flash[:error] = apicast_configuration_driven ? flash_message(:apicast_not_not_reverted) :  flash_message(:apicast_not_not_upgraded)
    end

    redirect_to toggle_land_path
  end

  protected

  def find_registry_policies
    policies_list = Policies::PoliciesListService.call!(current_account, proxy: @proxy)
    @registry_policies = PoliciesListPresenter.new(policies_list).registry
  rescue StandardError => error
    @error = error
  end

  def edit_stale
    flash.now[:error] = flash_message(:stale_object)

    @proxy.reload
    @proxy.assign_attributes(proxy_params.except(:lock_version))

    render :show, status: :conflict
  end

  def flash_message(key, opts = {})
    translate(key, opts.reverse_merge(scope: :api_integrations_controller, raise: Rails.env.test?))
  end

  def proxy_pro_update
    if @proxy.update(proxy_params)
      update_mapping_rules_position
      flash[:notice] = flash_message(:proxy_pro_update_sucess)
      redirect_to :show
    else
      render :show
    end
  end

  def find_proxy
    @proxy = @service.proxy
  end

  def authorize
    authorize! :manage, :plans
    authorize! :edit, @service
  end

  def update_mapping_rules_position
    proxy_rules_attributes.each_value do |attrs|
      proxy_rule = @proxy.proxy_rules.find_by(id: attrs['id']) || next
      proxy_rule.set_list_position(attrs['position'])
    end
  end

  def proxy_rules_attributes
    # we need to permit proxy_rules_attributes: {} because for some reason we are accepting single proxy rule
    # and also hash with multiple `id: proxy_rule` values
    params.require(:proxy).permit(proxy_rules_attributes: {}).to_h.fetch(:proxy_rules_attributes, {})
  end

  PROXY_BASIC_PARAMS = [
    :lock_version,
    :auth_app_id,
    :auth_app_key,
    :api_backend,
    :hostname_rewrite,
    :oauth_login_url,
    :secret_token,
    :credentials_location,
    :auth_user_key,
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
    :error_limits_exceeded,
    :api_test_path,
    :policies_config,
    { proxy_rules_attributes: %i[_destroy id http_method pattern delta metric_id redirect_url position last] },
    { oidc_configuration_attributes: OIDCConfiguration::Config::ATTRIBUTES + [:id] },
    { backend_api_configs_attributes: %i[_destroy id path] }
  ].freeze

  def proxy_params
    permitted_fields = PROXY_BASIC_PARAMS.dup

    if Rails.application.config.three_scale.apicast_custom_url || @proxy.saas_configuration_driven_apicast_self_managed?
      permitted_fields << :endpoint
      permitted_fields << :sandbox_endpoint
    end

    permitted_fields << :endpoint if @service.using_proxy_pro? || @proxy.saas_script_driven_apicast_self_managed?

    if provider_can_use?(:apicast_oidc)
      permitted_fields << :oidc_issuer_endpoint
      permitted_fields << :oidc_issuer_type
      permitted_fields << :jwt_claim_with_client_id
      permitted_fields << :jwt_claim_with_client_id_type
    end

    params.require(:proxy).permit(*permitted_fields)
  end

  def toggle_land_path
    @proxy.apicast_configuration_driven ? admin_service_integration_path(@service) : edit_admin_service_integration_path(@service)
  end
end
