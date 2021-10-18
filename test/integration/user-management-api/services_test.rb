# frozen_string_literal: true

require 'test_helper'

class Admin::Api::ServicesTest < ActionDispatch::IntegrationTest
  def setup
    @provider = FactoryBot.create :provider_account, :domain => 'provider.example.com'
    @service = FactoryBot.create(:service, :account => @provider)

    host! @provider.admin_domain
  end

  # Access token

  test 'show (access_token)' do
    User.any_instance.stubs(:has_access_to_all_services?).returns(false)
    user  = FactoryBot.create(:member, account: @provider, admin_sections: ['partners'])
    token = FactoryBot.create(:access_token, owner: user, scopes: 'account_management')

    get(admin_api_service_path(@service))
    assert_response :forbidden
    get(admin_api_service_path(@service), params: { access_token: token.value })
    assert_response :not_found
    User.any_instance.expects(:member_permission_service_ids).returns([@service.id]).at_least_once
    get(admin_api_service_path(@service), params: { access_token: token.value })
    assert_response :success
  end

  # Provider key

  test 'index' do
    get admin_api_services_path, params: { :provider_key => @provider.api_key, :format => :xml }

    assert_response :success

    assert_services @response.body, { :account_id => @provider.id }
  end

  test 'show' do
    get admin_api_service_path(@service), params: { :provider_key => @provider.api_key, :format => :xml }

    assert_response :success

    assert_service @response.body, {:account_id => @provider.id, :id => @service.id}
  end

  pending_test 'show with wrong id' do
  end

  test 'create' do
    Settings::Switch.any_instance.stubs(:allowed?).returns(true)

    post(admin_api_services_path, params: { :provider_key => @provider.api_key, :format => :xml, :name => 'service foo' })

    assert_response :success
    assert_service(@response.body,
                   { :account_id => @provider.id, :name => "service foo" })
    assert @provider.services.find_by_name("service foo")
  end

  test 'create with json body parameters' do
    @provider.settings.allow_multiple_services!
    @provider.provider_constraints.update_attributes!(max_services: 5)

    assert_difference @provider.services.method(:count) do

      post(admin_api_services_path(provider_key: @provider.api_key), params: { name: 'foo' }.to_json, session: { 'CONTENT_TYPE' => 'application/json' })
      assert_response :success
    end
  end

  test 'create fails without multiple_services switch' do
    post(admin_api_services_path, params: { :provider_key => @provider.api_key, :format => :xml, :name => 'service foo' })

    assert_response :forbidden
  end

  test 'update' do
    put("/admin/api/services/#{@service.id}", params: { :provider_key => @provider.api_key, :format => :xml, :name => 'new service name' })

    assert_response :success
    assert_service(@response.body,
                   { :account_id => @provider.id, :name => "new service name" })
    @service.reload
    assert @service.name == "new service name"
  end

  test 'update the support email' do
    put(admin_api_service_path(@service), params: { provider_key: @provider.api_key, :format => :xml, support_email: 'supp@topo.com' })

    assert_response :success

    @service.reload

    assert_equal 'supp@topo.com', @service.support_email
  end

  pending_test 'update with wrong id' do
  end

  test 'destroy' do
    # Creating at least two services so that one service still remains
    @provider.settings.allow_multiple_services!
    _other_service  = FactoryBot.create(:simple_service, account: @provider)

    access_token = FactoryBot.create(:access_token, owner: @provider.admins.first, scopes: 'account_management')
    delete admin_api_service_path @service.id, access_token: access_token.value, format: :json

    assert_response 200
    assert_raise(ActiveRecord::RecordNotFound) { Service.accessible.find(@service.id) }
  end

  class WithReadOnlyTokenTest < ActionDispatch::IntegrationTest
    disable_transactional_fixtures!

    def setup
      @provider = FactoryBot.create :provider_account, :domain => 'provider.example.com'
      @service = FactoryBot.create(:service, :account => @provider)

      host! @provider.admin_domain
    end

    test 'update with a ro token fails' do
      user = FactoryBot.create(:simple_admin, account: @provider)
      ro_token = FactoryBot.create(:access_token, owner: user, scopes: 'account_management', permission: 'ro')
      rw_token = FactoryBot.create(:access_token, owner: user, scopes: 'account_management', permission: 'rw')

      put("/admin/api/services/#{@service.id}", params: { access_token: rw_token.value, format: :xml, name: 'new service name' })
      assert_response :success
      @service.reload
      assert_equal 'new service name', @service.name

      put("/admin/api/services/#{@service.id}", params: { access_token: ro_token.value, format: :xml, name: 'other service name' })
      assert_response :forbidden
      @service.reload
      assert_equal 'new service name', @service.name
    end
  end

end
