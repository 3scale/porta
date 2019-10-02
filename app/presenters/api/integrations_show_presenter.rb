# frozen_string_literal: true

class Api::IntegrationsShowPresenter

  def initialize(proxy)
    @proxy = proxy
  end

  attr_reader :proxy

  def production_proxy_endpoint
    last_production_config.production_endpoint || proxy.default_production_endpoint
  end

  def staging_proxy_endpoint
    last_sandbox_config.sandbox_endpoint || proxy.default_staging_endpoint
  end

  def last_sandbox_config
    @last_sandbox_config ||= proxy_configs.sandbox.last!
  end

  def last_production_config
    @last_production_config ||= proxy_configs.production.last!
  end

  def next_sandbox_config_version
    any_sandbox_configs? ? last_sandbox_config.version + 1 : 1
  end

  def next_production_config_version
    return unless any_sandbox_configs?
    last_sandbox_config.version
  end

  def any_sandbox_configs?
    return @any_sandbox_configs if defined?(@any_sandbox_configs)

    @any_sandbox_configs = any_configs?(:sandbox)
  end

  def any_production_configs?
    return @any_production_configs if defined?(@any_production_configs)

    @any_production_configs = any_configs?(:production)
  end

  def environments_have_same_config?
    return @environments_have_same_config if defined?(@environments_have_same_config)

    @environments_have_same_config = begin
      production_version && sandbox_version == production_version
    end
  end

  def apiap?
    provider_can_use? :api_as_product
  end

  def apicast_config_ready?
    if apiap?
      proxy.service.backend_apis.any?
    else
      any_sandbox_configs?
    end
  end

  def test_state_modifier
    return 'is-untested' if @proxy.account.provider_can_use?(:api_as_product)

    case @proxy.api_test_success
    when true
      'is-successful'
    when false
      'is-erroneous'
    else
      'is-untested'
    end
  end

  delegate :pending_affecting_changes?, :service, to: :proxy

  private :proxy

  private

  delegate :proxy_configs, :provider_can_use?, to: :proxy

  def sandbox_version
    @sandbox_version ||= last_version_of(:sandbox) if any_sandbox_configs?
  end

  def production_version
    @production_version ||= last_version_of(:production) if any_production_configs?
  end

  def last_version_of(environment)
    simple_proxy_configs.public_send(environment).last.version
  end

  def simple_proxy_configs
    @simple_proxy_configs ||= proxy_configs.select(:version)
  end

  def any_configs?(environment)
    proxy_configs.public_send(environment).exists?
  end
end

