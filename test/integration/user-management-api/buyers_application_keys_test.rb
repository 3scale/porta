# frozen_string_literal: true

require 'test_helper'

class Admin::Api::BuyersApplicationKeysTest < ActionDispatch::IntegrationTest
  disable_transactional_fixtures!

  include FieldsDefinitionsHelpers

  include TestHelpers::BackendClientStubs

  def setup
    @provider = FactoryBot.create :provider_account, :domain => 'provider.example.com'
    @provider.first_service!.update_attribute(:backend_version, '2')

    @buyer = FactoryBot.create(:buyer_account, :provider_account => @provider)
    @buyer.buy! @provider.default_account_plan
    @app_plan = FactoryBot.create :application_plan, :issuer => @provider.first_service!
    @buyer.buy! @app_plan
    @buyer.reload
    host! @provider.admin_domain

    ApplicationKey.enable_backend!
  end

  test 'create (access_token)' do
    User.any_instance.stubs(:has_access_to_all_services?).returns(false)
    user  = FactoryBot.create(:member, account: @provider, admin_sections: ['partners'])
    token = FactoryBot.create(:access_token, owner: user, scopes: 'account_management')
    app   = @buyer.bought_cinstances.last

    post(admin_api_account_application_keys_path(@buyer, app, key: 'alaska'))
    assert_response :forbidden
    post(admin_api_account_application_keys_path(@buyer, app, key: 'alaska'), params: { access_token: token.value })
    assert_response :not_found
    User.any_instance.expects(:member_permission_service_ids).returns([app.issuer.id]).at_least_once
    post(admin_api_account_application_keys_path(@buyer, app, key: 'alaska'), params: { access_token: token.value })
    assert_response :success
  end

  test 'create key' do
    new_key = "foo-key"

    application = @buyer.bought_cinstances.last
    expect_backend_create_key(application, new_key)

    post(admin_api_account_application_keys_path(@buyer, application,
                                                      :key => new_key,
                                                      :format => :xml), params: { :provider_key => @provider.api_key })

    assert_response :success
    assert_application(body,
                       { :id => application.id, "keys/key" => new_key })
  end


  test 'create long key' do
    key = "k"*255

    application = @buyer.bought_cinstances.last
    expect_backend_create_key(application, key)

    post(admin_api_account_application_keys_path(@buyer, application,
                                                      :key => key,
                                                      :format => :xml), params: { :provider_key => @provider.api_key })

    assert_response :success
    assert_application(@response.body,
                       { :id => application.id, "keys/key" => key })
  end

  test 'destroy key' do
    rm_key = "foo-key"

    application = @buyer.bought_cinstances.last
    expect_backend_create_key(application, rm_key)
    expect_backend_delete_key(application, rm_key)


    application.application_keys.add(rm_key)

    delete(admin_api_account_application_key_path(@buyer.id, application.id, rm_key),
                :provider_key => @provider.api_key,
                :method => "_destroy", :format => :xml)

    assert_response :success
  end

  test 'destroy not existing key returns not found' do
    rm_key = "foo-key"

    application = @buyer.bought_cinstances.last
    expect_backend_create_key(application, rm_key)
    expect_backend_delete_key(application, rm_key)
    application.application_keys.add(rm_key)

    delete(admin_api_account_application_key_path(@buyer.id, application.id, "fake-foo-key"),
                :provider_key => @provider.api_key,
                :method => "_destroy", :format => :xml)

    assert_response :not_found

    delete(admin_api_account_application_key_path(@buyer.id, application.id, rm_key), params: { :provider_key => @provider.api_key, :format => :xml })

    assert_response :success

  end


end
