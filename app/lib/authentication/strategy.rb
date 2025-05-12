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

      def build_strategy(type)
        inflected_type = Rails.autoloaders.main.inflector.camelize(type.to_s, {})
        strategy_class_name = "Authentication::Strategy::#{inflected_type}"
        strategy_class_name.constantize
      rescue NameError
        Rails.logger.debug("Tried to build a non-existing strategy: #{type}")
      end
    end
  end
end
