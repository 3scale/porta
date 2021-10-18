# frozen_string_literal: true

require 'test_helper'

class Provider::Admin::AuthenticationProvidersControllerTest < ActionDispatch::IntegrationTest

  setup do
    @provider = FactoryBot.create(:provider_account)
    @provider.settings.allow_branding
    FactoryBot.create(:admin, account: @provider)
    login_provider @provider
  end

  test 'GET index' do
    get provider_admin_authentication_providers_path
    assert_response :success
    provider_rows = css_select 'table.data tbody tr'
    assert_equal AuthenticationProvider.available.count, provider_rows.size
    AuthenticationProvider.available.each do |auth_provider|
      assert_select 'table.data td.provider', count: 1, text: auth_provider.human_kind
    end
  end

  test 'GET edit' do
    authentication_provider = FactoryBot.create(:authentication_provider, account: @provider)
    get edit_provider_admin_authentication_provider_path(authentication_provider)
    assert_response :success
  end

  test 'GET new' do
    @provider.settings.deny_branding!
    assert_difference -> {@provider.authentication_providers.count } do
      get new_provider_admin_authentication_provider_path(kind: :github)
    end
    auth_provider = @provider.authentication_providers.find_by!(kind: :github)
    assert_redirected_to provider_admin_authentication_provider_path(auth_provider)
  end

  test 'authentication_provider_attributes' do
    attributes = {
      name: "my-github-name", system_name: "system_name", client_id: "client_id", client_secret: "client_secret",
      token_url: "http://token_url", user_info_url: "http://user_info_url", authorize_url: "http://authorize_url",
      site: "http://site", kind: 'github', skip_ssl_certificate_verification: true
    }
    assert_difference -> {@provider.authentication_providers.count } do
      post provider_admin_authentication_providers_path, params: { authentication_provider: attributes }
    end

    github = @provider.authentication_providers.find_by! kind: :github
    assert_redirected_to edit_provider_admin_authentication_provider_path(github)

    assert_equal 'client_id', github.client_id

    put provider_admin_authentication_provider_path(github), params: { authentication_provider: {client_id: 'clientID'} }
    assert_template 'provider/admin/authentication_providers/show'
    github.reload
    assert_equal 'clientID', github.client_id
  end

  test 'POST create success' do
    attrs = FactoryBot.attributes_for(:authentication_provider)
    refute @provider.authentication_providers.find_by kind: attrs[:kind]
    post provider_admin_authentication_providers_path, params: { authentication_provider: attrs }
    authentication_provider = @provider.authentication_providers.find_by! kind: attrs[:kind]
    assert_redirected_to edit_provider_admin_authentication_provider_path(authentication_provider)
  end

  test 'PUT update automatically_approve_accounts' do
    authentication_provider = FactoryBot.create(:authentication_provider, account: @provider)
    refute authentication_provider.automatically_approve_accounts
    put provider_admin_authentication_provider_path(authentication_provider), params: { authentication_provider: {automatically_approve_accounts: true} }
    authentication_provider.reload
    assert authentication_provider.automatically_approve_accounts
  end

  test 'PUT update updates the param correctly and renders show' do
    authentication_provider = FactoryBot.create(:authentication_provider, account: @provider, client_id: 'client_id')
    put provider_admin_authentication_provider_path(authentication_provider, authentication_provider: {client_id: 'clientID'})
    assert_template 'provider/admin/authentication_providers/show'
    assert_equal 'Authentication provider updated', flash[:notice]
    assert_equal 'clientID', authentication_provider.reload.client_id
  end

  test 'PUT update renders edit when there are errors' do
    @provider.settings.allow_branding
    AuthenticationProvider.any_instance.stubs(:update_attributes).returns(false)
    authentication_provider = FactoryBot.create(:authentication_provider, account: @provider, client_id: 'client_id')
    put provider_admin_authentication_provider_path(authentication_provider, authentication_provider: {client_id: 'clientID'})
    assert_template 'provider/admin/authentication_providers/edit'
    assert_equal 'Authentication provider has not been updated', flash[:notice]
  end

  test 'PUT publish_or_hide updates \'published\' correctly and renders show' do
    @provider.settings.allow_branding
    authentication_provider = FactoryBot.create(:authentication_provider, account: @provider)
    patch publish_or_hide_provider_admin_authentication_provider_path(authentication_provider, authentication_provider: {published: true})
    assert_template 'provider/admin/authentication_providers/show'
    assert_equal 'Authentication provider updated', flash[:notice]
    assert authentication_provider.reload.published
  end

  test 'PUT publish_or_hide renders show when there are errors and there is github branding denied' do
    @provider.settings.deny_branding
    AuthenticationProvider.any_instance.stubs(:update_attributes).returns(false)
    authentication_provider = FactoryBot.create(:github_authentication_provider, account: @provider, branding_state: 'threescale_branded')
    patch publish_or_hide_provider_admin_authentication_provider_path(authentication_provider, authentication_provider: {published: true})
    assert_template 'provider/admin/authentication_providers/show'
    assert_equal 'Authentication provider has not been updated', flash[:notice]
  end

  test 'DELETE destroy' do
    authentication_provider = FactoryBot.create(:authentication_provider, account: @provider)

    delete provider_admin_authentication_provider_path(authentication_provider)

    assert_redirected_to provider_admin_authentication_providers_path

    assert_raise ActiveRecord::RecordNotFound do
      authentication_provider.reload
    end
  end

end
