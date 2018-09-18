require 'test_helper'

class Policies::PoliciesListServiceTest < ActiveSupport::TestCase

  def setup
    @service = Policies::PoliciesListService
  end

  def test_call
    ThreeScale.config.sandbox_proxy.stubs(apicast_registry_url: 'https://apicast-staging.proda.example.com/policies')
    stub_request(:get, "https://apicast-staging.proda.example.com/policies")
      .to_return(status: 200, body: "{\"policies\":[{\"schema\":\"1\"}]}",
                  headers: { 'Content-Type' => 'application/json' })

    policies = @service.call
    assert_equal [{"schema" => "1"}], policies
  end
end
