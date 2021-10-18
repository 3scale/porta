# frozen_string_literal: true

require 'test_helper'

class EnterpriseApiApplicationsTest < ActionDispatch::IntegrationTest

  include TestHelpers::BackendClientStubs
  include TestHelpers::ApiPagination

  def setup
    stub_backend_get_keys

    @provider = FactoryBot.create :provider_account, :domain => 'provider.example.com'
    @service = @provider.services.first

    @buyer = FactoryBot.create(:buyer_account, :provider_account => @provider)
    @buyer.buy! @provider.default_account_plan

    @application_plan = FactoryBot.create :application_plan, :issuer => @provider.default_service
    @application_plan.publish!
    @buyer.buy! @application_plan

    host! @provider.admin_domain
  end

  #TODO: test extra fields in indexes

  # Access token

  test 'index (access_token)' do
    User.any_instance.stubs(:has_access_to_all_services?).returns(false)
    user  = FactoryBot.create(:member, account: @provider, admin_sections: ['partners'])
    token = FactoryBot.create(:access_token, owner: user, scopes: 'account_management')

    get(admin_api_applications_path)
    assert_response :forbidden
    get(admin_api_applications_path, params: { access_token: token.value })
    assert_response :success
    User.any_instance.expects(:member_permission_service_ids).returns([@service.id]).at_least_once
    get(admin_api_applications_path, params: { access_token: token.value, service_id: @service.id })
    assert_response :success
  end

  # Provider key

  test 'index on backend v2' do
    @service.backend_version = '2'
    @service.save!
    get admin_api_applications_path(:format => :xml), params: { :provider_key => @provider.api_key }

    assert_response :success
    assert_applications @response.body, :backend => "2"
  end

  test 'index on backend v1' do
    @service.backend_version = '1'
    @service.save!

    get admin_api_applications_path(:format => :xml), params: { :provider_key => @provider.api_key }

    assert_response :success
    assert_applications @response.body, :backend => "1"
  end

  test 'index on backend oauth' do
    @service.backend_version = 'oauth'
    @service.save!

    get admin_api_applications_path(:format => :xml), params: { :provider_key => @provider.api_key }

    assert_response :success
    assert_applications @response.body, :backend => :oauth
  end

  test 'pagination is off unless needed' do
    get admin_api_applications_path(:format => :xml), params: { :provider_key => @provider.api_key }

    assert_response :success
    assert_not_pagination @response.body, "applications"
  end

  test 'index is paginated' do
    # creating more apps
    #TODO move app creation to helpers...
    buyer = FactoryBot.create(:buyer_account, :provider_account => @provider)
    buyer.buy! @provider.default_account_plan
    @application_plan = FactoryBot.create :application_plan, :issuer => @provider.first_service!
    @application_plan.publish!
    buyer.buy! @application_plan

    get(admin_api_applications_path(:format => :xml), params: { :provider_key => @provider.api_key, :per_page => 1 })

    assert_response :success
    assert_pagination @response.body, "applications"
  end

  test 'pagination per_page has a maximum allowed' do
    # Two applications because pagination should be shown only if needed, so total_entries > per_page
    application_plan = FactoryBot.create :application_plan, :issuer => @provider.first_service!
    @buyer.buy! application_plan

    max_per_page = set_api_pagination_max_per_page(:to => 1)

    get(admin_api_applications_path(:format => :xml), params: { :provider_key => @provider.api_key, :per_page => (max_per_page +1) })

    assert_response :success
    assert_pagination @response.body, "applications", :per_page => max_per_page
  end

  test 'pagination page defaults to 1 for invalid values' do
    # Two applications because pagination should be shown only if needed, so total_entries > per_page
    application_plan = FactoryBot.create :application_plan, :issuer => @provider.first_service!
    @buyer.buy! application_plan

    max_per_page = set_api_pagination_max_per_page(:to => 1)

    get(admin_api_applications_path(:format => :xml), params: { :provider_key => @provider.api_key, :page => "invalid" })

    assert_response :success
    assert_pagination @response.body, "applications", :current_page => "1"
  end

  test 'pagination per_page defaults to max for invalid values' do
    # Two applications because pagination should be shown only if needed, so total_entries > per_page
    application_plan = FactoryBot.create :application_plan, :issuer => @provider.first_service!
    @buyer.buy! application_plan

    max_per_page = set_api_pagination_max_per_page(:to => 1)

    get(admin_api_applications_path(:format => :xml), params: { :provider_key => @provider.api_key, :per_page => "invalid" })

    assert_response :success
    assert_pagination @response.body, "applications", :per_page => max_per_page
  end

  test 'pagination per_page defaults to max for values lesser than 1' do
    application_plan = FactoryBot.create :application_plan, :issuer => @provider.first_service!
    @buyer.buy! application_plan
    application_plan2 = FactoryBot.create :application_plan, :issuer => @provider.first_service!
    @buyer.buy! application_plan2

    max_per_page = set_api_pagination_max_per_page(:to => 2)

    get(admin_api_applications_path(:format => :xml), params: { :provider_key => @provider.api_key, :per_page => "-1" })

    assert_response :success
    assert_pagination @response.body, "applications", :per_page => "2"
  end

  pending_test 'index returns fields defined'

  context 'find' do
    setup do
      @provider.reload if @provider.provided_cinstances.empty?
      @application = @provider.provided_cinstances.last
    end

    should 'return 404 on non found app' do
      get(find_admin_api_applications_path(:format => :xml), params: { :user_key => "SHAWARMA", :provider_key => @provider.api_key })

      assert_xml_404
    end

    should 'find by user_key on backend v1' do
      @service.backend_version = '1'
      @service.save!

      get(find_admin_api_applications_path(:format => :xml), params: { :user_key => @application.user_key, :provider_key => @provider.api_key })

      assert_response :success
      assert_application(@response.body,
                         { :id => @application.id,
                           :user_key => @application.user_key })
    end

    should 'find by app_id on backend v2' do
      @service.backend_version = '2'
      @service.save!

      get(find_admin_api_applications_path(:format => :xml), params: { :app_id => @application.application_id, :provider_key => @provider.api_key })

      assert_response :success
      assert_application(@response.body,
                         { :id => @application.id,
                           :user_account_id => @buyer.id,
                           :application_id => @application.application_id })
    end

    should 'find by app_id on backend oauth' do
      @service.backend_version = 'oauth'
      @service.save!

      get(find_admin_api_applications_path(:format => :xml), params: { :app_id => @application.application_id, :provider_key => @provider.api_key })

      assert_response :success
      assert_application(@response.body,
                         { :id => @application.id,
                           :user_account_id => @buyer.id,
                           :application_id => @application.application_id })
    end


    should 'find by app_id on backend oidc' do

      @service.backend_version = 'oidc'
      @service.save!

      get(find_admin_api_applications_path(:format => :xml), params: { :app_id => @application.application_id, :provider_key => @provider.api_key })

      assert_response :success
      assert_application(@response.body,
                         { :id => @application.id,
                           :user_account_id => @buyer.id,
                           :application_id => @application.application_id, oidc: true})
    end

    should 'return the oidc_configuration' do
      @service.backend_version = 'oidc'
      @service.save!

      config = @service.proxy.oidc_configuration
      config.service_accounts_enabled = true
      config.save!

      get(find_admin_api_applications_path(:format => :json), params: { :app_id => @application.application_id, :provider_key => @provider.api_key })

      assert_response :success

      json = JSON.parse(@response.body)
      assert json.dig('application', 'oidc_configuration', 'service_accounts_enabled')
      assert json.dig('application', 'oidc_configuration', 'standard_flow_enabled')
      refute json.dig('application', 'oidc_configuration', 'implicit_flow_enabled')
      refute json.dig('application', 'oidc_configuration', 'direct_access_grants_enabled')
    end

    should 'find by id (application_id) on any backend' do
      @service.backend_version = 'oauth'
      @service.save!

      get(find_admin_api_applications_path(:format => :xml), params: { :application_id => @application.id, :provider_key => @provider.api_key })

      assert_response :success
      assert_application(@response.body,
                         { :id => @application.id,
                           :user_account_id => @buyer.id,
                           :application_id => @application.application_id })

      @service.backend_version = '2'
      @service.save!

      get(find_admin_api_applications_path(:format => :xml), params: { :application_id => @application.id, :provider_key => @provider.api_key })

      assert_response :success
      assert_application(@response.body,
                         { :id => @application.id,
                           :user_account_id => @buyer.id,
                           :application_id => @application.application_id })

      @service.backend_version = '1'
      @service.save!

      get(find_admin_api_applications_path(:format => :xml), params: { :application_id => @application.id, :provider_key => @provider.api_key })

      assert_response :success
      assert_application(@response.body,
                         { :id => @application.id,
                           :user_account_id => @buyer.id,
                           :user_key => @application.user_key  })

    end

  end # find

  test 'security wise: applications is access denied in buyer side' do
    host! @provider.domain
    get admin_api_applications_path(:format => :xml), params: { :provider_key => @provider.api_key }

    assert_response :forbidden
  end

end
