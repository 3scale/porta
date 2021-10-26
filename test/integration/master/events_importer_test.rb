# frozen_string_literal: true

require 'test_helper'

class Master::EventsImporterTest < ActionDispatch::IntegrationTest
  def setup
    @provider = FactoryBot.create(:simple_provider)
    ::Events.stubs(shared_secret: 'shared-secret!')
  end

  test 'forbids master event import if on admin portal' do
    host! @provider.self_domain

    ThreeScale.config.stubs(tenant_mode: 'multitenant')
    post master_events_import_url, params: { secret: 'shared-secret!' }
    assert_response :forbidden
  end

  test 'allows master event import if on master wildcard' do
    host! Account.master.self_domain

    ThreeScale.config.stubs(tenant_mode: 'multitenant')
    post master_events_import_url, params: { secret: 'shared-secret!' }
    assert_response :success

    ThreeScale.config.stubs(tenant_mode: 'master')
    post master_events_import_url, params: { secret: 'shared-secret!' }
    assert_response :success
  end
end
