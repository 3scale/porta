# frozen_string_literal: true

# A method #provider_can_use? should be always available without
# the need of explicitly specifying the caller. You are able to
# call `provider_can_use?(:oauth_proxy)` in controller, view
# but also in a Service.
#
module Logic
  module RollingUpdates
    class UnknownFeatureError < StandardError; end
    class UnknownFeatureConfigError < StandardError
      include Bugsnag::MetaData

      def initialize(feature)
        name = feature.name
        type = feature.class.name
        config = Features::Yaml.config
        self.bugsnag_meta_data = {
          feature: name,
          config: config
        }
        super "Unknown configuration for feature ':#{name}' of type #{type}"
      end
    end

    def self.config
      Rails.configuration.three_scale.rolling_updates
    end

    def self.enabled?
      config.enabled
    end

    def self.skipped?
      config.skipped
    end

    def self.disabled?
      !enabled?
    end

    def self.feature(name)
      feature = name.to_s.camelize

      if Features.const_defined?(feature, false)
        Features.const_get(feature, false)
      elsif Logic::RollingUpdates.config.raise_error_unknown_features
        raise UnknownFeatureError, "Unknown provider feature #{name}"
      end
    end

    module Features
      class Yaml
        def self.config
          Rails.configuration.three_scale.rolling_updates.features || {}.freeze
        end
      end

      class Base
        attr_reader :provider
        delegate :master?, :provider?, :enterprise?, :provider_can_use?, to: :provider
        delegate :id, to: :provider, prefix: true

        OPENSHIFT_PROVIDER_ID = 2

        def initialize(provider)
          @provider = provider
        end

        def name
          self.class.name.demodulize.underscore.to_sym
        end

        def state
          Yaml.config[name]
        end

        def enabled?
          case state
          when true, false
            state
          when Array
            state.include?(provider_id)
          when nil
            missing_config
          else
            raise_invalid_config
          end
        end

        def raise_invalid_config
          raise UnknownFeatureConfigError, self
        end
      end

      class ServiceMeshIntegration < Base
        def missing_config
          false
        end
      end

      class OAuthApi < Base
        def missing_config
          true
        end
      end

      class OldCharts < Base
        def missing_config
          false
        end
      end

      class NewProviderDocumentation < Base
        def missing_config
          false
        end
      end

      class ProxyPro < Base
        def missing_config
          false
        end
      end

      class ProxyPrivateBasePath < Base
        def missing_config
          false
        end
      end

      class IndependentMappingRules < Base
        def missing_config
          false
        end
      end

      class InstantBillPlanChange < Base
        def missing_config
          false
        end
      end

      class ServicePermissions < Base
        def enabled?
          super || enterprise? || master?
        end

        def missing_config
          false
        end
      end

      class PublishedServicePlanSignup < Base
        def missing_config
          false
        end
      end

      class AsyncApicastDeploy < Base
        def missing_config
          false
        end
      end

      class DuplicateApplicationId < Base
        def enabled?
          super || enterprise?
        end

        def missing_config
          false
        end
      end

      class DuplicateUserKey < Base
        def enabled?
          super || enterprise?
        end

        def missing_config
          false
        end
      end

      class PlanChangesWizard < Base
        def enabled?
          super || master?
        end

        def missing_config
          Rails.env.test?
        end
      end

      class ProviderSSO < Base
        def enabled?
          super || enterprise?
        end

        def missing_config
          false
        end
      end

      class RequireCcOnSignup < Base
        def enabled?
          super || master? || provider_created_at < Date.new(2016, 7, 5)
        end

        def missing_config
          false
        end

        def provider_created_at
          provider.created_at.try(:to_date) || Date.today
        end
      end

      class ApicastPerService < Base
        def enabled?
          super || enterprise? || master?
        end

        def missing_config
          false
        end
      end

      class NewNotificationSystem < Base
        def missing_config
          master? || provider?
        end
      end

      class CMSApi < Base
        def enabled?
          super || master?
        end

        def missing_config
          false
        end
      end

      class ApicastV2 < Base
        def missing_config
          master?
        end
      end

      class ApicastV1 < Base
        def missing_config
          Rails.env.test? || provider_created_at < Date.new(2017, 6, 30)
        end

        def provider_created_at
          provider.created_at.try(:to_date) || Date.today
        end
      end

      class ApicastOIDC < Base
        def missing_config
          false
        end
      end

      class Forum < Base
        def missing_config
          true
        end
      end

      class BillableContracts < Base
        def missing_config
          false
        end
      end

      class Policies < Base
        def missing_config
          false
        end
      end

      class PolicyRegistry < Base
        def enabled?
          super && provider_can_use?(:policies)
        end

        def missing_config
          false
        end
      end

      class PolicyRegistryUi < PolicyRegistry
        def enabled?
          super && provider_can_use?(:policy_registry)
        end
      end

      class Unknown < Base
        def missing_config
          false
        end
      end
    end

    module Provider
      def enterprise?
        # bought plan depends on a bought cinstance
        if has_bought_cinstance? && bought_plan.present?
          bought_plan.system_name.to_s.include?('enterprise')
        end
      end

      def provider_can_use?(feature)
        return provider_account&.provider_can_use?(feature) if buyer?

        return false if Logic::RollingUpdates.skipped?
        return true if Logic::RollingUpdates.disabled?

        rolling_update(feature).enabled?
      rescue UnknownFeatureConfigError, UnknownFeatureError
        raise
      rescue StandardError => e
        System::ErrorReporting.report_error(e)
        (Rails.env.test? || Rails.env.development?) ? raise(e) : false
      end

      def rolling_update(name)
        feature = ::Logic::RollingUpdates.feature(name) || ::Logic::RollingUpdates.feature(:unknown)
        feature.new(self)
      end
    end

    module Service
      private

      def provider_can_use?(fresh_feature)
        provider.provider_can_use?(fresh_feature)
      end
    end

    module Controller
      def self.included(klass)
        klass.helper_method :provider_can_use?
      end

      protected

      def provider_can_use!(feature)
        raise ActiveRecord::RecordNotFound unless provider_can_use?(feature)
      end

      def provider_can_use?(fresh_feature)
        return false if Logic::RollingUpdates.skipped?
        return true if Logic::RollingUpdates.disabled?

        current_user&.impersonation_admin? || current_account.provider_can_use?(fresh_feature)
      end
    end
  end
end
