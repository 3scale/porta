# frozen_string_literal: true

require 'test_helper'

class Stats::Api::ApplicationsTest < ActionDispatch::IntegrationTest
  def setup
    @cinstance = FactoryBot.create :cinstance
    host! @cinstance.provider_account.admin_domain
    @admin = @cinstance.provider_account.admins.first.username
  end

  test 'usage_response_code with no data as json' do
    provider_login_with @admin, 'supersecret'
    get "/stats/api/applications/#{@cinstance.id}/usage_response_code.json", params: { period: 'day', response_code: 200, timezone: 'Madrid', skip_change: false }

    assert_response :success
    assert_content_type 'application/json'

    response = ActiveSupport::JSON.decode(@response.body)
    response["values"] == [0] * 25
    response["change"] == 0.0
  end
end
