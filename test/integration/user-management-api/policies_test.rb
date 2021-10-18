# frozen_string_literal: true

require 'test_helper'

class Admin::Api::PoliciesTest < ActionDispatch::IntegrationTest

  def setup
    @provider = FactoryBot.create(:provider_account)

    host! @provider.admin_domain
  end

  def test_index
    rolling_updates_on
    Policies::PoliciesListService.expects(:call).with(@provider).returns("{\"cors\":[{\"schema\":\"1\"}]}")
    get admin_api_policies_path(format: :json), params: { provider_key: @provider.api_key }
    assert_match "{\"cors\":[{\"schema\":\"1\"}]}", response.body
  end
end
