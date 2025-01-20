# frozen_string_literal: true

require 'test_helper'

# Admin Portal SSO integration
class Provider::Admin::Account::AuthenticationProvidersControllerTest < ActionDispatch::IntegrationTest

  setup do
    @provider = FactoryBot.create(:provider_account)
    FactoryBot.create(:admin, account: @provider)
    login_provider @provider
  end

  test 'GET index' do
    get provider_admin_authentication_providers_path
    assert_response :success
    assert_template :index
  end

  test 'POST create success' do
    %w[keycloak auth0].each do |kind|
      attrs = { client_id: 'client', client_secret: 'secret', site: 'http://example.com', kind: kind }
      assert_not @provider.self_authentication_providers.find_by(kind: kind, client_id: attrs[:client_id])
      post provider_admin_account_authentication_providers_path, params: { authentication_provider: attrs }

      authentication_provider = @provider.self_authentication_providers.find_by! kind: kind, client_id: attrs[:client_id]
      assert_equal attrs[:site].strip, authentication_provider.site
      assert_redirected_to provider_admin_account_authentication_provider_path(authentication_provider)
      follow_redirect!
      assert_response :success
      assert_match 'SSO integration created', flash[:notice]
    end
  end

  test 'POST create with site with whitespaces' do
    %w[keycloak auth0].each do |kind|
      attrs = { client_id: 'client', client_secret: 'secret', site: '  http://example.com  ', kind: kind }
      post provider_admin_account_authentication_providers_path, params: { authentication_provider: attrs }

      assert_nil @provider.self_authentication_providers.find_by kind: kind, client_id: attrs[:client_id]
      assert_response :success
      assert_template :new
      assert_match 'SSO integration could not be created', flash[:error]
      assert_match "contain whitespaces", response.body
    end
  end

  test 'GET show' do
    authentication_provider = FactoryBot.create(:self_authentication_provider, account: @provider)
    get provider_admin_account_authentication_provider_path(authentication_provider)
    assert_response :success
    assert_template :show
  end

  test 'GET edit' do
    authentication_provider = FactoryBot.create(:self_authentication_provider, account: @provider)
    get edit_provider_admin_account_authentication_provider_path(authentication_provider)
    assert_response :success
    assert_template :edit
  end

  test 'PATCH update params' do
    authentication_provider = FactoryBot.create(:self_authentication_provider, account: @provider)
    assert_not authentication_provider.skip_ssl_certificate_verification
    patch provider_admin_account_authentication_provider_path(authentication_provider), params: { authentication_provider: { skip_ssl_certificate_verification: '1' } }

    assert_redirected_to provider_admin_account_authentication_provider_path(authentication_provider)
    assert authentication_provider.reload.skip_ssl_certificate_verification
  end

  test 'PATCH update invalid URL' do
    authentication_provider = FactoryBot.create(:keycloak_self_authentication_provider, account: @provider)

    patch provider_admin_account_authentication_provider_path(authentication_provider), params: { authentication_provider: { site: '  http://example.com  ' } }

    assert_response :success
    assert_template :edit
    assert_match 'SSO integration could not be updated', flash[:error]
    assert_match "contain whitespaces", response.body
  end

  test 'DELETE destroy' do
    authentication_provider = FactoryBot.create(:self_authentication_provider, account: @provider)

    delete provider_admin_account_authentication_provider_path(authentication_provider)

    assert_redirected_to provider_admin_account_authentication_providers_path

    assert_raise ActiveRecord::RecordNotFound do
      authentication_provider.reload
    end
  end
end
