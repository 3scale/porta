# frozen_string_literal: true

class ProxyDeploymentService
  delegate :apicast_configuration_driven,
           :deployable?,
           :provider,
           :proxy_configs, to: :@proxy

  alias apicast_configuration_driven? apicast_configuration_driven

  class UnknownStageError < ArgumentError; end

  def self.call(*args)
    new(*args).call
  end

  def initialize(proxy, environment: :staging)
    @proxy = proxy
    @environment = environment
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

    if apicast_configuration_driven?
      deploy_v2
    else
      deploy_v2 && deploy_production_v2
    end
  end

  def deploy_production
    deploy_production_v2 if apicast_configuration_driven?
  end

  def deploy_v2
    ApicastV2DeploymentService.new(@proxy).call(environment: :sandbox)
  end

  def deploy_production_v2
    newest_sandbox_config = proxy_configs.sandbox.newest_first.first

    newest_sandbox_config.clone_to(environment: :production) if newest_sandbox_config
  end

end
