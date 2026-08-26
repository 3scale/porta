# frozen_string_literal: true

require 'test_helper'

class Stats::Api::ApplicationsTest < ActionDispatch::IntegrationTest
  def setup
    @cinstance = FactoryBot.create :cinstance
    host! @cinstance.provider_account.internal_admin_domain
    @admin = @cinstance.provider_account.admins.first.username
  end

  test 'usage_response_code with no data as json' do
    provider_login_with @admin, 'superSecret1234#'
    get usage_response_code_stats_api_applications_path(@cinstance, format: :json), params: {
      period: 'day', response_code: 200, timezone: 'Madrid', skip_change: false
    }

    assert_response :success
    assert_media_type 'application/json'

    response = ActiveSupport::JSON.decode(@response.body)
    assert_equal response["values"], [0] * 25
    assert response["change"].to_d.zero?
  end
end
