# frozen_string_literal: true

require 'test_helper'

class Stats::Data::ServicesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @application = FactoryBot.create :cinstance
    host! @application.provider_account.internal_admin_domain
    user = @application.provider_account.admins.first!
    @token = FactoryBot.create(:access_token, owner: user, scopes: %w[stats], permission: 'rw').value
  end

  attr_reader :application, :token

  test 'top applications' do
    params = { access_token: token, since: '2021-08-30 00:00:00', period: :day, metric_name: 'hits' }
    get top_applications_stats_data_services_path(application.service, format: :json), params: params
    assert_response :success
  end

  test 'missing params' do
    params = { access_token: token, since: '2021-08-30 00:00:00', period: :day, metric_name: 'hits' }
    get top_applications_stats_data_services_path(application.service, format: :json), params: params.except(:since)
    assert_response :bad_request

    get top_applications_stats_data_services_path(application.service, format: :json), params: params.except(:period)
    assert_response :bad_request

    get top_applications_stats_data_services_path(application.service, format: :json), params: params.except(:metric_name)
    assert_response :bad_request
  end
end
