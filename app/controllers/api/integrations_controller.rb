class Api::IntegrationsController < Api::BaseController
  before_action :find_service
  before_action :find_proxy
  before_action :authorize

  activate_menu :serviceadmin, :integration, :configuration
  sublayout 'api/service'

  PLUGIN_LANGUAGES = %w(ruby java python nodejs php rest csharp).freeze

  rescue_from ActiveRecord::StaleObjectError, with: :edit_stale

  def edit
    @latest_lua = current_account.proxy_logs.first
    @deploying =  ThreeScale::TimedValue.get(deploying_hosted_proxy_key)
    @ever_deployed_hosted = current_account.hosted_proxy_deployed_at.present?
  end

  def settings

  end

  def update
    if @service.using_proxy_pro? && !@proxy.apicast_configuration_driven
      proxy_pro_update
    elsif @proxy.save_and_deploy(proxy_params)
      environment = @proxy.service_mesh_integration? ? 'Production' : 'Staging'
      flash[:notice] = flash_message(:update_success, environment: environment)
      update_onboarding_mapping_bubble
      update_mapping_rules_position

      if @proxy.send_api_test_request!
        onboarding.bubble_update('api')
        done_step(:api_sandbox_traffic) if ApiClassificationService.test(@proxy.api_backend).real_api?
        return redirect_to edit_path
      end
      render :edit

    else
      attrs = proxy_rules_attributes
      splitted = attrs.keys.group_by { |key| attrs[key]['_destroy'] == '1' }

      @marked_for_destroy = splitted[true]
      @marked_for_update = splitted[false]

      flash.now[:error] = flash_message(:update_error)
      @api_test_form_error = true

      render :edit
    end
  end

  def update_production
    @proxy.deploy_production
    ThreeScale::TimedValue.set(deploying_hosted_proxy_key, true, 5*60 )
    ThreeScale::Analytics.track(current_user, 'Hosted Proxy deployed')
    flash[:notice] = flash_message(:update_production_success)

    done_step(:apicast_gateway_deployed, final_step=true) if ApiClassificationService.test(@proxy.api_backend).real_api?
    onboarding.bubble_update('deployment')

    redirect_to action: :edit, anchor: 'proxy'
  end

  def update_onpremises_production
    if @proxy.update_attributes(proxy_params)
      flash[:notice] = flash_message(:update_onpremises_production_success)
      redirect_to action: :edit, anchor: 'production'
    else
      render :edit
    end
  end

  def promote_to_production
    if @proxy.deploy_production
      flash[:notice] = flash_message(:promote_to_production_success)
    else
      flash[:error] = flash_message(:promote_to_production_error)
    end
    redirect_to action: :show
  end

  def show
    respond_to do |format|
      format.html do
        @show_presenter = Api::IntegrationsShowPresenter.new(@proxy)
      end

      format.zip do
        onboarding.bubble_update('deployment')

        source = if provider_can_use?(:apicast_per_service)
                   Apicast::UserSource.new(current_user)
                 else
                   Apicast::ProviderSource.new(@service.account)
        end

        generator = Apicast::ZipGenerator.new(source)

        send_file generator.data,
                  type: 'application/zip',
                  disposition: 'attachment',
                  filename: 'proxy_configs.zip'
      end
    end
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

  def edit_stale
    flash.now[:error] = flash_message(:stale_object)

    @proxy.reload
    @proxy.assign_attributes(proxy_params.except(:lock_version))

    @last_message_bus_id = nil # don't want MessageBus showing flash message

    render :edit, status: :conflict
  end

  def flash_message(key, opts = {})
    translate(key, opts.reverse_merge(scope: :api_integrations_controller, raise: Rails.env.test?))
  end

  def proxy_pro_update
    if @proxy.update_attributes(proxy_params)
      update_onboarding_mapping_bubble
      onboarding.bubble_update('api')
      update_mapping_rules_position
      flash[:notice] = flash_message(:proxy_pro_update_sucess)
      redirect_to edit_path
    else
      render :edit
    end
  end

  def async_update
    if (@deploy_id = @proxy.save_and_async_deploy(proxy_params, current_user))
      flash.now[:notice] = flash_message(:async_update_success)

      render :edit
    else
      attrs = params.fetch(:proxy, {}).fetch(:proxy_rules_attributes,{})
      splitted = attrs.keys.group_by { |key| attrs[key]['_destroy'] == '1' }

      @marked_for_destroy = splitted[true]
      @marked_for_update = splitted[false]

      flash.now[:error] = flash_message(:async_update_error)
      @api_test_form_error = true

      render :edit
    end
  end

  def edit_path
    last_message_id = @last_message_bus_id

    {
      action: :edit,
      last_id: last_message_id,
      anchor: last_message_id ? 'second_nav' : 'proxy'
    }.compact
  end

  def find_proxy
    @proxy = @service.proxy

    @last_message_bus_id = params.fetch(:last_id) { last_message_bus_id(@proxy) } if message_bus?(@proxy)
  end

  def last_message_bus_id(proxy)
    MessageBus.last_id("/integration/#{proxy.to_gid_param}/#{proxy.lock_version + 1}")
  end

  def message_bus?(proxy)
    proxy.oidc? && ZyncWorker.config.message_bus
  end

  def authorize
    authorize! :manage, :plans
    authorize! :edit, @service
  end

  def update_mapping_rules_position
    proxy_rules_attributes.each do |_, attrs|
      proxy_rule = @proxy.proxy_rules.find_by_id(attrs['id'])
      proxy_rule.set_list_position(attrs['position']) if proxy_rule
    end
  end

  def proxy_rules_attributes
    params.fetch(:proxy, {}).fetch(:proxy_rules_attributes, {})
  end

  def proxy_params
    basic_fields = [
      :lock_version,
      :auth_app_id, :auth_app_key, :api_backend, :hostname_rewrite, :oauth_login_url,
      :secret_token, :credentials_location, :auth_user_key, :error_status_auth_failed,
      :error_headers_auth_failed, :error_auth_failed, :error_status_auth_missing,
      :error_headers_auth_missing, :error_auth_missing, :error_status_no_match,
      :error_headers_no_match, :error_no_match, :api_test_path, :policies_config,
      proxy_rules_attributes: [:_destroy, :id, :http_method, :pattern, :delta, :metric_id, :redirect_url, :position],
      oidc_configuration_attributes: OIDCConfiguration::Config::ATTRIBUTES
    ]

    if Rails.application.config.three_scale.apicast_custom_url || @proxy.saas_configuration_driven_apicast_self_managed?
      basic_fields << :endpoint
      basic_fields << :sandbox_endpoint
    end

    basic_fields << :endpoint if @service.using_proxy_pro? || @proxy.saas_script_driven_apicast_self_managed?

    basic_fields << :oidc_issuer_endpoint if provider_can_use?(:apicast_oidc)

    params.require(:proxy).permit(*basic_fields)
  end

  def deploying_hosted_proxy_key
    "#{current_account.id}/deploying_hosted"
  end

  def update_onboarding_mapping_bubble
    onboarding.bubble_update('mapping') if proxy_rules_added_for_last_method_metric?
  end

  def proxy_rules_added_for_last_method_metric?
    @proxy.proxy_rules.size > 1
  end

  def toggle_land_path
    @proxy.apicast_configuration_driven ? admin_service_integration_path(@service) : edit_admin_service_integration_path(@service)
  end
end
