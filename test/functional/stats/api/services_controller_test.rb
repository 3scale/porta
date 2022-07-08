# frozen_string_literal: true

require 'test_helper'

class Stats::Api::ServicesControllerTest < ActionController::TestCase
  test 'routes' do
    assert_routing({ method: :get, path: '/stats/api/services/1/usage.json' },            { service_id: '1', controller: 'stats/api/services', action: 'usage', format: 'json' })
    assert_routing({ method: :get, path: '/stats/api/services/1/usage.xml' },             { service_id: '1', controller: 'stats/api/services', action: 'usage', format: 'xml' })
    assert_routing({ method: :get, path: '/stats/api/services/1/top_applications.json' }, { service_id: '1', controller: 'stats/api/services', action: 'top_applications', format: 'json' })
    assert_routing({ method: :get, path: '/stats/api/services/1/top_applications.xml' },  { service_id: '1', controller: 'stats/api/services', action: 'top_applications', format: 'xml' })
  end

  test 'csv format for errors' do
    setup_data

    get :usage, params: { format: :csv, service_id: @provider.default_service.id, period: 'troloro' }
    assert_match %r{text/plain}, response.header['Content-Type']
    assert_equal 400, response.status
  end

  private

  # Example for future tests
  def setup_data
    @provider = FactoryBot.create :provider_account
    @buyer    = FactoryBot.create(:buyer_account, :provider_account => @provider, timezone: 'Mountain Time (US & Canada)')
    @app_plan = FactoryBot.create(:application_plan, :issuer => @provider.default_service)
    @app = @buyer.buy! @app_plan
    host! @provider.external_admin_domain
    login_provider @provider
  end
end
