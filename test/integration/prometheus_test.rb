# frozen_string_literal: true

require 'test_helper'

class PrometheusTest < ActionDispatch::IntegrationTest
  def setup
    config = ThreeScale.config.prometheus
    config.stubs(username: 'user', password: 'secret')
    @authorization = ActionController::HttpAuthentication::Basic.encode_credentials(config.username, config.password)
    Rails.application.routes_reloader.reload!
  end

  def teardown
    Rails.application.routes_reloader.reload!
  end

  test 'metrics on master domain' do
    host! master_account.self_domain

    get '/system/metrics', {}, authorization: @authorization
    assert_response :success

    assert_raises ActionController::RoutingError do
      get '/system/metrics'
    end
  end

  test 'metrics on provider admin domain' do
    provider = FactoryGirl.create(:simple_provider)

    host! provider.self_domain
    assert_raises ActionController::RoutingError do
      get '/system/metrics', {}, authorization: @authorization
    end
    assert_raises ActionController::RoutingError do
      get '/system/metrics'
    end
  end

  test 'metrics on provider domain' do
    provider = FactoryGirl.create(:simple_provider)
    host! provider.domain

    # The assertion is a bit different from admin domain as CMS has a wildcard route
    get '/system/metrics', {}, authorization: @authorization
    assert_response :not_found

    get '/system/metrics'
    assert_response :not_found
  end
end
