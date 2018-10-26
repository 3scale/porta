# frozen_string_literal: true

module ServiceDiscovery
  class WellKnownFetcher
    include ServiceDiscovery::Config

    # TODO: Retry strategy
    #   That can be complicated as it will be per unicorn worker
    #   and we do not want to block the server
    #   Probably this could be required at boot time
    #   then if cluster is is not available after X retries,
    #   disable the service discovery.
    def call
      request = RestClient::Request.new(
        method: :get,
        url: well_known_url,
        verify_ssl: verify_ssl,
        timeout: timeout,
        open_timeout: open_timeout,
        log: Rails.logger
      )
      request.execute do |response|
        if response.code == 200
          json = JSON.parse(response.body)
          # The endpoint could be better in case of Keycloak
          json.merge!(userinfo_endpoint: "#{server_url}/apis/user.openshift.io/v1/users/~")
          ActiveSupport::OrderedOptions.new.merge!(json.symbolize_keys).freeze
        else
          nil
        end
      end
    rescue => e
      # TODO: Improve error logging
      Rails.logger.debug("[Service Discovery] Cannot fetch the #{well_known_url} configuration. Exception: #{e.message}")
      nil
    end
  end
end