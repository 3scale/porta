module Authentication
  module Strategy

    class << self
      def build(site_account)
        type = site_account.settings.authentication_strategy

        build_strategy(type).new(site_account)
      end

      def build_provider(provider_account)
        build_strategy(:provider_oauth2).new(provider_account, true) # TODO: make this configurable
      end

      protected

      def build_strategy(type)
        strategy_class_name = "authentication/strategy/#{type}".camelize
        strategy_class_name.constantize
      end
    end
  end
end
