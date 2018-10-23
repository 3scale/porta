# frozen_string_literal: true

module ServiceDiscovery
  class TokenRetriever

    def initialize(user=nil)
      @user = user
    end

    def config
      ThreeScale.config.service_discovery
    end

    def authentication_method
      ActiveSupport::StringInquirer.new(config.authentication_method.presence || 'service_account')
    end

    def access_token
      if authentication_method.oauth?
        @user.provided_access_tokens.valid.first
      else
        config.bearer_token
      end
    end
  end
end
