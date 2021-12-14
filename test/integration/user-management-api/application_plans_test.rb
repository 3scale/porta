# frozen_string_literal: true

require 'test_helper'

class Admin::Api::ApplicationPlansTest < ActionDispatch::IntegrationTest
  def setup
    @provider = FactoryBot.create(:provider_account, domain: 'provider.example.com')
    @service = @provider.default_service

    plan = FactoryBot.create(:application_plan, issuer: @service)
    plan.publish!

    FactoryBot.create(:account_plan, issuer: @provider)
    FactoryBot.create(:service_plan, issuer: @provider.default_service)

    host! @provider.admin_domain
  end

  class AccessTokenTest < Admin::Api::ApplicationPlansTest
    def setup
      super
      user = FactoryBot.create(:member, account: @provider, admin_sections: %w[partners plans])
      @token = FactoryBot.create(:access_token, owner: user, scopes: 'account_management')

      User.any_instance.stubs(:has_access_to_all_services?).returns(false)
    end

    test 'index with no token' do
      get admin_api_service_application_plans_path(@service)
      assert_response :forbidden
    end

    test 'index with access to no services' do
      User.any_instance.expects(:member_permission_service_ids).returns([]).at_least_once
      get admin_api_service_application_plans_path(@service), params: params
      assert_response :not_found
    end

    test 'index with access to some service' do
      User.any_instance.expects(:member_permission_service_ids).returns([@service.id]).at_least_once
      get admin_api_service_application_plans_path(@service), params: params
      assert_response :success
    end

    test 'index' do
      User.any_instance.stubs(:has_access_to_all_services?).returns(true)
      User.any_instance.expects(:member_permission_service_ids).never
      get admin_api_service_application_plans_path(@service), params: params
      assert_response :success
    end

    private

    def access_token_params(token = @token)
      { access_token: token.value }
    end

    alias params access_token_params
  end

  class ProviderKeyTest < Admin::Api::ApplicationPlansTest
    def teardown
      @xml = nil
    end

    test 'fast track: index' do
      get admin_api_application_plans_path(provider_key: @provider.api_key, format: :xml)
      assert_response :success
      assert_only_application_plans xml
    end

    test 'security wise: index is access denied in buyer side' do
      host! @provider.domain
      get admin_api_application_plans_path(provider_key: @provider.api_key, format: :xml)
      assert_response :forbidden
    end

    test 'index' do
      service = FactoryBot.create(:service, account: @provider)
      FactoryBot.create(:application_plan, issuer: service)

      get admin_api_service_application_plans_path(service, provider_key: @provider.api_key, format: :xml)
      assert_response :success

      assert(xml.xpath('.//plans/plan/service_id').all? { |t| t.text == service.id.to_s })
      assert_only_application_plans xml
    end

    test 'show' do
      get admin_api_service_application_plan_path(@service, @service.application_plans.first, provider_key: @provider.api_key, format: :xml)
      assert_response :success
      assert_an_application_plan xml, @service
    end

    test 'create' do
      post admin_api_service_application_plans_path(@service, format: :xml), params: params.merge({ name: 'awesome application plan',
                                                                                                    state_event: 'publish' })
      assert_response :success

      assert_an_application_plan xml, @service
      assert_equal 'awesome application plan', xml.xpath('.//plan/name').children.first.to_s
      assert_equal 'published', xml.xpath('.//plan/state').children.first.to_s
    end

    test 'create without name fails' do
      post admin_api_service_application_plans_path(@service, format: :xml), params: params.merge({ name: '' })
      assert_equal '422', response.code
    end

    test 'update' do
      plan = FactoryBot.create(:application_plan, issuer: @service, name: 'namy')

      put admin_api_service_application_plan_path(@service, plan, format: :xml), params: params.merge({ name: 'new name',
                                                                                                        state_event: 'publish' })
      assert_response :success

      assert_an_application_plan xml, @service
      assert_equal 'new name', xml.xpath('.//plan/name').children.first.to_s
      assert_equal 'published', xml.xpath('.//plan/state').children.first.to_s
      assert_equal 'false', xml.xpath('.//plan/@default').first.value
    end

    test 'default' do
      plan = FactoryBot.create(:application_plan, issuer: @service, name: 'namy')
      plan.publish!

      put default_admin_api_service_application_plan_path(@service, plan, provider_key: @provider.api_key, format: :xml)
      assert_response :ok

      assert_an_application_plan xml, @service
      assert_equal 'true', xml.xpath('.//plan/@default').first.value
    end

    test 'destroy' do
      application_plan = FactoryBot.create(:application_plan, issuer: @service)

      delete admin_api_service_application_plan_path(@service, application_plan, format: :xml), params: params.merge({ method: "_destroy" })
      assert_response :success
      assert_not @response.body.presence

      assert_raise ActiveRecord::RecordNotFound do
        application_plan.reload
      end
    end

    test 'destroy returns error when deletion failed' do
      application_plan = FactoryBot.create(:application_plan, issuer: @service)
      FactoryBot.create(:cinstance, plan: application_plan)

      delete admin_api_service_application_plan_path(@service, application_plan, format: :xml), params: params.merge({ method: '_destroy' })
      assert_response :forbidden
      assert_xml_error(@response.body, "This application plan cannot be deleted")
    end

    private

    def xml
      @xml ||= Nokogiri::XML::Document.parse(@response.body)
    end

    def provider_key_params
      { provider_key: @provider.api_key }
    end

    alias params provider_key_params
  end
end
