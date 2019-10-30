# frozen_string_literal: true

module ProxyLogic
  module Deployment
    def deployable?
      Service::DeploymentOption.gateways.include?(deployment_option) || service_mesh_integration?
    end

    def service_mesh_integration?
      Service::DeploymentOption.service_mesh.include?(deployment_option)
    end

    DEPLOYMENT_OPTION_CHANGED = ->(record) { record.changed_attributes.key?(:deployment_option) }

    def deployment_option_changed?
      [self, service].any?(&DEPLOYMENT_OPTION_CHANGED)
    end

    # We want to autosave when Service#deployment_option changed
    def changed_for_autosave?
      deployment_option_changed? or super
    end

    def ready_to_deploy?
      api_test_success
    end

    def deployment_strategy
      strategy = case deployment_option
                 when 'self_managed' then SelfManagedAPIcast
                 when 'hosted' then HostedAPIcast
                 end

      strategy&.new(self)
    end

    def deployment_strategy_apiap
      HostedAPIcast.new self
    end

    def deploy!
      deploy
    end

    def deploy
      return true unless deployable?

      if service_mesh_integration?
        deploy_service_mesh_integration
      elsif apicast_configuration_driven
        deploy_v2
      else
        deploy_v1
      end
    end

    def deploy_service_mesh_integration
      return unless provider_can_use?(:service_mesh_integration)
      deploy_v2 && deploy_production_v2
    end

    def deploy_v1
      deployment = ProviderProxyDeploymentService.new(provider)

      success = deployment.deploy(self)

      analytics.track('Sandbox Proxy Deploy', success: success)

      success
    end

    def deploy_v2
      deployment = ApicastV2DeploymentService.new(self)

      deployment.call(environment: 'sandbox')
    end

    def deploy_production
      if apicast_configuration_driven
        deploy_production_v2
      elsif ready_to_deploy?
        provider.deploy_production_apicast
      end
    end

    def deploy_production_v2
      newest_sandbox_config = proxy_configs.sandbox.newest_first.first
      newest_sandbox_config&.clone_to(environment: :production)
    end

    def async_deploy(user)
      ProviderProxyDeploymentService.async_deploy(user, self)
    end

    def deployment_option
      # Preparation for migrating the column from Service to Proxy
      attribute = __method__
      deployment_option = service&.read_attribute(attribute) || self[attribute]
      deployment_option&.inquiry
    end

    class DeploymentStrategy
      # @return Proxy
      attr_reader :proxy

      # @return Service
      delegate :service, to: :proxy

      # @param [Proxy] proxy
      def initialize(proxy)
        @proxy = proxy
      end

      def attributes
        {
          staging_endpoint: default_staging_endpoint,
          production_endpoint: default_production_endpoint
        }
      end

      def default_staging_endpoint; end

      def default_production_endpoint; end

      def default_staging_endpoint_apiap; end

      def default_production_endpoint_apiap; end

      protected

      delegate :provider, to: :service
      delegate :subdomain, to: :provider, prefix: true, allow_nil: true

      def config
        proxy.class.config
      end

      def generate(name)
        template = config.fetch(name.try(:to_sym)) { return }

        format template, {
          system_name: service.parameterized_system_name, account_id: service.account_id,
          tenant_name: provider_subdomain,
          env: proxy.proxy_env, port: proxy.proxy_port
        }
      end
    end

    class HostedAPIcast < DeploymentStrategy
      def default_staging_endpoint
        staging_endpoint = proxy.apicast_configuration_driven ? :apicast_staging_endpoint : :sandbox_endpoint
        generate(staging_endpoint)
      end

      def default_production_endpoint
        production_endpoint = proxy.apicast_configuration_driven ? :apicast_production_endpoint : :hosted_proxy_endpoint
        generate(production_endpoint)
      end

      def default_staging_endpoint_apiap
        default_staging_endpoint
      end

      def default_production_endpoint_apiap
        default_production_endpoint
      end
    end

    class SelfManagedAPIcast < DeploymentStrategy
      def default_staging_endpoint
        staging_endpoint = proxy.apicast_configuration_driven ? nil : :sandbox_endpoint
        generate(staging_endpoint)
      end
    end
  end
end
