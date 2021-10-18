# frozen_string_literal: true

require 'test_helper'

class Admin::Api::ProvidersTest < ActionDispatch::IntegrationTest
  include FieldsDefinitionsHelpers

  def setup
    @provider = FactoryBot.create :provider_account, domain: 'yo-provider.example.com'
    host! @provider.admin_domain
  end

  test 'get to show' do
    get admin_api_provider_path(format: :json), params: { provider_key: @provider.api_key }

    assert_response :success

    account = JSON.parse(response.body)['account']

    assert_equal @provider.admin_domain, account['admin_domain']
    assert_equal @provider.domain, account['domain']
  end

  test 'update support emails test' do
    put admin_api_provider_path(format: :json), params: { provider_key: @provider.api_key, from_email: 'from@op.pl', support_email: 'supsup@ssup.pl', finance_support_email: 'fino@op.pl' }

    assert_response :success
    @provider.reload

    assert_equal 'from@op.pl', @provider.from_email
    assert_equal 'supsup@ssup.pl', @provider.support_email
    assert_equal 'fino@op.pl',  @provider.finance_support_email
  end

end
