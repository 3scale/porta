require 'test_helper'

class Master::Devportal::AuthControllerTest < ActionController::TestCase

  setup do
    host! master_account.domain

    @provider = FactoryBot.create(:simple_provider)
    @authentication_provider = FactoryBot.create(:authentication_provider, account: @provider)
  end

  test '#show must redirect to the login dev portal of the provider' do
    get :show, domain: @provider.domain, system_name: @authentication_provider.system_name, code: 'A1234', plan_id: 42
    assert_redirected_to "http://#{@provider.domain}/auth/#{@authentication_provider.system_name}/callback?code=A1234&master=true&plan_id=42"
  end
end
