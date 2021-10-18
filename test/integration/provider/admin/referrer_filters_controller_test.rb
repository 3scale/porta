# frozen_string_literal: true

require 'test_helper'

class Provider::Admin::ReferrerFiltersControllerTest < ActionDispatch::IntegrationTest

  HEADERS_XHR = {'HTTP_X_REQUESTED_WITH' => 'XMLHttpRequest'}.freeze

  def setup
    super
    @provider  = FactoryBot.create(:provider_account)
    @buyer     = FactoryBot.create(:buyer_account, provider_account: @provider)
    app_plan   = FactoryBot.create(:application_plan, issuer: @provider.default_service)
    @cinstance = @buyer.buy! app_plan
    @referrer  = 'referrer.example.com'
  end

  attr_reader :provider, :cinstance, :referrer

  class ProviderWithPermissionTest < Provider::Admin::ReferrerFiltersControllerTest
    def setup
      super
      login! provider
    end

    test 'create' do
      post provider_admin_application_referrer_filters_path(application_id: cinstance.to_param, referrer_filter: referrer), session: HEADERS_XHR

      assert_response :success
      assert_template 'create'
    end

    test 'create with error' do
      ReferrerFilter.any_instance.stubs(persisted?: false)

      post provider_admin_application_referrer_filters_path(application_id: cinstance.to_param, referrer_filter: referrer), session: HEADERS_XHR

      assert_response :success
      assert_template 'error'
    end

    test 'delete' do
      id = cinstance.referrer_filters.add(referrer).id

      delete provider_admin_application_referrer_filter_path(application_id: cinstance.to_param, id: id), session: HEADERS_XHR

      assert_response :success
    end
  end

  class ProviderWithoutPermissionTest < Provider::Admin::ReferrerFiltersControllerTest
    def setup
      super
      login! FactoryBot.create(:provider_account)
    end

    test 'create' do
      post provider_admin_application_referrer_filters_path(application_id: cinstance.to_param, referrer_filter: referrer), session: HEADERS_XHR
      assert_response :not_found
    end

    test 'delete' do
      id = cinstance.referrer_filters.add(referrer).id

      delete provider_admin_application_referrer_filter_path(application_id: cinstance.to_param, id: id), session: HEADERS_XHR

      assert_response :not_found
    end
  end

end
