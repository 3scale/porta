# frozen_string_literal: true

require 'test_helper'

class EnterpriseApiApplicationsTest < ActionDispatch::IntegrationTest
  include TestHelpers::BackendClientStubs
  include TestHelpers::ApiPagination

  def setup
    stub_backend_get_keys

    @provider = FactoryBot.create(:provider_account, domain: 'provider.example.com')
    @service = @provider.services.first

    @buyer = FactoryBot.create(:buyer_account, provider_account: @provider)
    @buyer.buy! @provider.default_account_plan

    @application_plan = FactoryBot.create(:application_plan, issuer: @provider.default_service)
    @application_plan.publish!
    @application = @buyer.buy! @application_plan

    # Create additional apps to have more data
    @buyer.buy! @application_plan

    host! @provider.admin_domain
  end

  #TODO: test extra fields in indexes

  class AccessTokenTest < EnterpriseApiApplicationsTest
    def setup
      super
      user = FactoryBot.create(:member, account: @provider, admin_sections: ['partners'])
      @token = FactoryBot.create(:access_token, owner: user, scopes: 'account_management')
    end

    protected

    def access_token_params(token = @token)
      { access_token: token.value }
    end

    alias params access_token_params
  end

  class WithAccessToAllServicesTest < AccessTokenTest
    def setup
      super
      User.any_instance.stubs(:has_access_to_all_services?).returns(true)
    end

    test '#index without token' do
      get admin_api_applications_path
      assert_response :forbidden
    end

    test '#index' do
      User.any_instance.expects(:member_permission_service_ids).never
      get admin_api_applications_path, params: params.merge({ service_id: @service.id })
      assert_response :success
      assert_applications_count @response.body, @token.owner.accessible_cinstances.size
    end
  end

  class WithoutAccessToAllServices < AccessTokenTest
    def setup
      super
      User.any_instance.stubs(:has_access_to_all_services?).returns(false)
    end

    test '#index without token' do
      get admin_api_applications_path
      assert_response :forbidden
    end

    test '#index with access to some service' do
      User.any_instance.expects(:member_permission_service_ids).returns([@service.id]).at_least_once
      get admin_api_applications_path, params: params.merge({ service_id: @service.id })

      assert_response :success
      assert_applications_count @response.body, @service.cinstances.size
    end

    test '#index with access to no service' do
      User.any_instance.expects(:member_permission_service_ids).returns([]).at_least_once
      get admin_api_applications_path, params: params.merge({ service_id: @service.id })

      assert_response :success
      assert_applications_count @response.body, 0
    end
  end

  class ProviderKeyTest < EnterpriseApiApplicationsTest
    protected

    def private_key_params
      { provider_key: @provider.api_key }
    end

    alias params private_key_params

    def target
      { id: @application.id, user_account_id: @buyer.id, application_id: @application.application_id }
    end
  end

  class PaginationTest < ProviderKeyTest
    def setup
      super
      @service = FactoryBot.create(:service, account: @provider)
      @total_entries = 5
      @total_entries.times do
        @buyer.buy! FactoryBot.create(:application_plan, issuer: @service)
      end
      @max_per_page = set_api_pagination_max_per_page(to: 4)
    end

    def teardown
      reset_pagination_config!
    end

    attr_reader :total_entries, :max_per_page

    test 'pagination is off if total_entries <= per_page' do
      set_api_pagination_max_per_page(to: total_entries)

      get admin_api_applications_path(format: :xml), params: params
      assert_response :success

      assert_applications_count @response.body, total_entries
      assert_not_pagination @response.body, "applications"
    end

    test 'index is paginated' do
      get admin_api_applications_path(format: :xml), params: params.merge({ per_page: 1 })

      assert_response :success
      assert_applications_count @response.body, 1
      assert_pagination @response.body, "applications"
    end

    test 'pagination per_page has a maximum allowed' do
      get admin_api_applications_path(format: :xml), params: params.merge({ per_page: max_per_page + 1 })

      assert_response :success
      assert_applications_count @response.body, max_per_page
      assert_pagination @response.body, "applications", per_page: max_per_page
    end

    test 'pagination page defaults to 1 for invalid values' do
      get admin_api_applications_path(format: :xml), params: params.merge({ page: "invalid", per_page: 1 })

      assert_response :success
      assert_applications_count @response.body, 1
      assert_pagination @response.body, "applications", current_page: '1'
    end

    test 'pagination per_page defaults to max for invalid values' do
      get admin_api_applications_path(format: :xml), params: params.merge({ per_page: "invalid" })

      assert_response :success
      assert_applications_count @response.body, max_per_page
      assert_pagination @response.body, "applications", per_page: max_per_page
    end

    test 'per_page defaults to max for values lesser than 1' do
      get admin_api_applications_path(format: :xml), params: params.merge({ per_page: "-1" })

      assert_response :success
      assert_applications_count @response.body, max_per_page
      assert_pagination @response.body, "applications", per_page: max_per_page
    end

    private

    def params
      super.merge({ service_id: @service.id })
    end
  end

  class EndpointsTest < ProviderKeyTest
    pending_test 'index returns fields defined'

    test 'return 404 on non found app' do
      get find_admin_api_applications_path(format: :xml), params: params.merge({ user_key: "SHAWARMA" })
      assert_xml_404
    end

    test 'security wise: applications is access denied in buyer side' do
      host! @provider.domain
      get admin_api_applications_path(format: :xml), params: params

      assert_response :forbidden
    end
  end

  class OIDCBackendTest < ProviderKeyTest
    def setup
      super
      @service.backend_version = 'oidc'
      @service.save!
    end

    test 'find by app_id' do
      get find_admin_api_applications_path(format: :xml), params: params.merge({ app_id: @application.application_id })

      assert_response :success
      assert_application(@response.body, target.merge({ oidc: true }))
    end

    test 'return the oidc_configuration' do
      config = @service.proxy.oidc_configuration
      config.service_accounts_enabled = true
      config.save!

      get find_admin_api_applications_path(format: :json), params: params.merge({ app_id: @application.application_id })
      assert_response :success

      json = JSON.parse(@response.body)
      assert json.dig('application', 'oidc_configuration', 'service_accounts_enabled')
      assert json.dig('application', 'oidc_configuration', 'standard_flow_enabled')
      assert_not json.dig('application', 'oidc_configuration', 'implicit_flow_enabled')
      assert_not json.dig('application', 'oidc_configuration', 'direct_access_grants_enabled')
    end
  end

  class OauthBackendTest < EndpointsTest
    def setup
      super
      @service.backend_version = 'oauth'
      @service.save!
    end

    should 'index on backend oauth' do
      get admin_api_applications_path(format: :xml), params: params

      assert_response :success
      assert_applications @response.body, backend: :oauth
    end

    should 'find by id' do
      get find_admin_api_applications_path(format: :xml), params: params.merge({ application_id: @application.id })

      assert_response :success
      assert_application(@response.body, target)
    end

    should 'find by app_id' do
      get find_admin_api_applications_path(format: :xml), params: params.merge({ app_id: @application.application_id })

      assert_response :success
      assert_application(@response.body, target)
    end
  end

  class BackendV1Test < EndpointsTest
    def setup
      super
      @service.backend_version = '1'
      @service.save!
    end

    should 'index on backend v1' do
      get admin_api_applications_path(format: :xml), params: params

      assert_response :success
      assert_applications @response.body, backend: '1'
    end

    should 'find by user_key' do
      get find_admin_api_applications_path(format: :xml), params: params.merge({ user_key: @application.user_key })

      assert_response :success
      assert_application(@response.body, { id: @application.id, user_key: @application.user_key })
    end

    should 'find by id' do
      get find_admin_api_applications_path(format: :xml), params: params.merge({ application_id: @application.id })

      assert_response :success
      assert_application(@response.body, { id: @application.id, user_account_id: @buyer.id, user_key: @application.user_key })
    end
  end

  class BackendV2Test < EndpointsTest
    def setup
      super
      @service.backend_version = '2'
      @service.save!
    end

    should 'index on backend v2' do
      get admin_api_applications_path(format: :xml), params: params

      assert_response :success
      assert_applications @response.body, backend: '2'
    end

    should 'find by id' do
      get find_admin_api_applications_path(format: :xml), params: params.merge({ application_id: @application.id })

      assert_response :success
      assert_application(@response.body, target)
    end

    should 'find by app_id' do
      get find_admin_api_applications_path(format: :xml), params: params.merge({ app_id: @application.application_id })

      assert_response :success
      assert_application(@response.body, target)
    end
  end
end
