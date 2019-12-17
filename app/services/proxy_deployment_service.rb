# frozen_string_literal: true

class ProxyDeploymentService
  delegate :apicast_configuration_driven,
           :deployable?,
           :service_mesh_integration?,
           :provider,
           :proxy_configs, to: :@proxy

  class UnknownStageError < ArgumentError; end

  def self.call(*args)
    new(*args).call
  end

  def initialize(proxy, environment: :staging, v1_compatible: false)
    @proxy = proxy
    @environment = environment
    @v1_compatible = v1_compatible
  end

  def call
    case @environment
    when :staging, :sandbox
      deploy
    when :production
      deploy_production
    else
      raise UnknownStageError, "Unknown environment: #{@stage}"
    end
  end

  private

  def deploy
    return true unless deployable?

    if service_mesh_integration?
      deploy_v2 && deploy_production_v2
    elsif apicast_configuration_driven
      deploy_v2
    elsif @v1_compatible
      deploy_v1
    end
  end

  # TODO: in order to include this method into 'call', do I need another service?
  def deploy_production
    if apicast_configuration_driven
      deploy_production_v2
    elsif @proxy.ready_to_deploy?
      provider.deploy_production_apicast
    end
  end

  # Deprecated
  def deploy_v1
    ApicastV1DeploymentService.new(provider).deploy(@proxy)
  end

  def deploy_v2
    ApicastV2DeploymentService.new(@proxy).call(environment: :sandbox)
  end

  def deploy_production_v2
    newest_sandbox_config = proxy_configs.sandbox.newest_first.first

    newest_sandbox_config.clone_to(environment: :production) if newest_sandbox_config
  end

end
