# frozen_string_literal: true

# This class is a Singleton
# It retrieves OpenShift OAuth configuration
# It uses the default as described https://docs.openshift.com/container-platform/3.10/architecture/additional_concepts/authentication.html#oauth-server-metadata
module ServiceDiscovery
  # Probably could be a Singleton
  class OAuthConfiguration
    include Singleton
    include ::ServiceDiscovery::Config

    attr_reader :retries
    delegate :authorization_endpoint, :userinfo_endpoint, :token_endpoint, to: :oauth_configuration, allow_nil: true

    def initialize
      super
      @mutex  = Mutex.new
      @retries = 0
      @fetcher = WellKnownFetcher.new
    end

    # Consider that when it is done via service_account, we do not need the oauth configuration
    # We already have a bearer_token to authenticate
    def oauth_configuration_ready?
      enabled && (service_account? || oauth_configuration.present?)
    end
    alias service_accessible? oauth_configuration_ready?

    def oauth_configuration
      return unless can_get_configuration?
      return @oauth_configuration if @oauth_configuration
      increment_retries_on_failure do
        @oauth_configuration = @fetcher.call
      end
    end

    private

    def can_get_configuration?
      enabled && oauth? && retries < max_retry
    end

    def increment_retries_on_failure
      @mutex.synchronize do
        yield.tap { |result| increment_failures unless result }
      end
    end

    def increment_failures
      @retries += 1
    end
  end
end
