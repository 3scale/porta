# frozen_string_literal: true

require 'jsonclient'

class Policies::PoliciesListService

  def self.call
    response = ::JSONClient.get(ThreeScale.config.sandbox_proxy.apicast_registry_url)
    response.body.symbolize_keys[:policies] if response.ok?
  end
end
