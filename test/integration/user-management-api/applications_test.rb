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
    @buyer.buy! @application_plan

    @application = @buyer.buy! @application_plan

    host! @provider.admin_domain
  end

  #TODO: test extra fields in indexes

  class AccessTokenTest < EnterpriseApiApplicationsTest
    def setup
      super
      user = FactoryBot.create(:member, account: @provider, admin_sections: ['partners'])
      @token = FactoryBot.create(:access_token, owner: user, scopes: 'account_management')
    end

    context 'with access to all services' do
      setup do
        User.any_instance.stubs(:has_access_to_all_services?).returns(true)
      end

      should '#index without token' do
        get admin_api_applications_path
        assert_response :forbidden
      end

      should '#index' do
        User.any_instance.expects(:member_permission_service_ids).never
        get admin_api_applications_path, params: params.merge({ service_id: @service.id })
        assert_response :success
      end
    end

    context 'without access to all services' do
      setup do
        User.any_instance.stubs(:has_access_to_all_services?).returns(false)
      end

      should '#index without token' do
        get admin_api_applications_path
        assert_response :forbidden
      end

      should '#index with access to some service' do
        User.any_instance.expects(:member_permission_service_ids).returns([@service.id]).at_least_once
        get admin_api_applications_path, params: params.merge({ service_id: @service.id })

        assert_response :success
        assert_equal 2, Nokogiri::XML::Document.parse(@response.body).xpath("//applications").children.length
      end

      should '#index with access to no service' do
        User.any_instance.expects(:member_permission_service_ids).returns([]).at_least_once
        get admin_api_applications_path, params: params.merge({ service_id: @service.id })

        assert_response :success
        assert_equal 0, Nokogiri::XML::Document.parse(@response.body).xpath("//applications").children.length
      end
    end

    private

    def access_token_params(token = @token)
      { access_token: token.value }
    end

    alias params access_token_params
  end

  class ProviderKeyTest < EnterpriseApiApplicationsTest
    context 'total_entries <= per_page' do
      should 'pagination is off' do
        get admin_api_applications_path(format: :xml), params: params

        assert_response :success
        assert_not_pagination @response.body, "applications"
      end
    end

    context 'total_entries > per_page' do
      setup do
        application_plan = FactoryBot.create(:application_plan, issuer: @provider.first_service!)
        @buyer.buy! application_plan
        application_plan2 = FactoryBot.create(:application_plan, issuer: @provider.first_service!)
        @buyer.buy! application_plan2
        @max_per_page = set_api_pagination_max_per_page(to: 1)
      end

      attr_reader :max_per_page

      should 'index is paginated' do
        get admin_api_applications_path(format: :xml), params: params.merge({ per_page: 1 })

        assert_response :success
        assert_pagination @response.body, "applications"
      end

      should 'pagination per_page has a maximum allowed' do
        get admin_api_applications_path(format: :xml), params: params.merge({ per_page: max_per_page + 1 })

        assert_response :success
        assert_pagination @response.body, "applications", per_page: max_per_page
      end

      should 'pagination page defaults to 1 for invalid values' do
        get admin_api_applications_path(format: :xml), params: params.merge({ page: "invalid" })

        assert_response :success
        assert_pagination @response.body, "applications", current_page: '1'
      end

      should 'pagination per_page defaults to max for invalid values' do
        get admin_api_applications_path(format: :xml), params: params.merge({ per_page: "invalid" })

        assert_response :success
        assert_pagination @response.body, "applications", per_page: max_per_page
      end

      should 'per_page defaults to max for values lesser than 1' do
        set_api_pagination_max_per_page(to: 2)

        get admin_api_applications_path(format: :xml), params: params.merge({ per_page: "-1" })

        assert_response :success
        assert_pagination @response.body, "applications", per_page: '2'
      end
    end

    pending_test 'index returns fields defined'

    test 'return 404 on non found app' do
      get find_admin_api_applications_path(format: :xml), params: params.merge({ user_key: "SHAWARMA" })
      assert_xml_404
    end

    context 'oidc backend' do
      setup do
        @service.backend_version = 'oidc'
        @service.save!
      end

      should 'find by app_id' do
        get find_admin_api_applications_path(format: :xml), params: params.merge({ app_id: @application.application_id })

        assert_response :success
        assert_application(@response.body, target.merge({ oidc: true }))
      end

      should 'return the oidc_configuration' do
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

    context 'backend is oauth' do
      setup do
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

    context 'backend is v1' do
      setup do
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

    context 'backend is v2' do
      setup do
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

    test 'security wise: applications is access denied in buyer side' do
      host! @provider.domain
      get admin_api_applications_path(format: :xml), params: params

      assert_response :forbidden
    end

    private

    def private_key_params
      { provider_key: @provider.api_key }
    end

    alias params private_key_params

    def target
      { id: @application.id, user_account_id: @buyer.id, application_id: @application.application_id }
    end
  end
end
