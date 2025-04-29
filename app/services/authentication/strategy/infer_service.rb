# frozen_string_literal: true

module Authentication
  module Strategy
    class InferService < ThreeScale::Patterns::Service

      def initialize(params, account, provider)
        @params = params
        @account = account
        @provider = provider
      end

      def call
        type = infer_type

        return build(:token) if impersonating?(type)
        return build(:provider_oauth2) if sso_enforced?

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
        type = provider? ? :provider_oauth2 : :oauth2 if type == :oauth2_base

        strategy_class(type).new(@provider, provider?)
      rescue InvalidStrategyError
        #return nil if no auth strategy was found
        nil
      end

      def impersonating?(type)
        type.present? && strategy_class(type) == Authentication::Strategy::Token
      end

      def provider?
        @account&.provider?
      end

      def sso_enforced?
        provider? && @account&.settings&.enforce_sso?
      end
    end
  end
end
