# frozen_string_literal: true

module Authentication
  module Strategy
    class InferService < ThreeScale::Patterns::Service

      def initialize(params, site_account, admin_domain: false)
        @params = params
        @site_account = site_account
        @admin_domain = admin_domain
      end

      def call
        type = infer_type

        return Authentication::Strategy::Null.new unless type
        return build(:provider_oauth2) if sso_enforced? && !impersonating?(type)

        build(type)
      end

      private

      STRATEGIES = %i[oauth2_base internal token].freeze

      def infer_type
        given_param_keys = @params.to_h.symbolize_keys.keys

        # Take the first strategy in STRATEGIES which expected_params are received in the request
        STRATEGIES.find { |type| strategy_class(type).expected_params.all? { given_param_keys.include? _1 } }
      end

      def strategy_class(type)
        Authentication::Strategy.build_strategy(type)
      end

      def build(type)
        type = @admin_domain ? :provider_oauth2 : :oauth2 if type == :oauth2_base

        strategy_class(type).new(@site_account, @admin_domain)
      end

      def impersonating?(type)
        type == :token
      end

      def sso_enforced?
        @admin_domain && @site_account.settings.enforce_sso?
      end
    end
  end
end
