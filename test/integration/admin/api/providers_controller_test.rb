# frozen_string_literal: true

require 'test_helper'

class Admin::Api::ProvidersControllerTest < ActionDispatch::IntegrationTest

  def setup
    @provider = FactoryBot.create(:provider_account)
    host! @provider.external_admin_domain
  end

  test '#update' do
    @provider.settings.finance.allow
    update_params = { account: { from_email: 'from@email.com', support_email: 'support@email.com',
                                 finance_support_email: 'finance@email.com', site_access_code: 'new-access-code'},
                      provider_key: @provider.provider_key, format: :json }
    put admin_api_provider_path(@provider, update_params)
    assert_response :ok

    @provider.reload
    assert_equal update_params[:account][:from_email],            @provider.from_email
    assert_equal update_params[:account][:support_email],         @provider.support_email
    assert_equal update_params[:account][:finance_support_email], @provider.finance_support_email
    assert_equal update_params[:account][:site_access_code],      @provider.site_access_code
  end

  test 'rejects finance_support_email when finance switch denied' do
    assert @provider.settings.finance.denied?
    put admin_api_provider_path(format: :json), params: {
      provider_key: @provider.provider_key,
      account: { support_email: 'ok@example.com', finance_support_email: 'hacked@example.com' }
    }
    assert_response :ok
    assert_equal 'ok@example.com', @provider.reload.support_email
    assert_nil @provider[:finance_support_email]
  end

end
