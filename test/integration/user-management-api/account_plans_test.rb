# frozen_string_literal: true

require 'test_helper'

class Admin::Api::AccountPlansTest < ActionDispatch::IntegrationTest
  def setup
    @provider = FactoryBot.create(:provider_account, domain: 'provider.example.com')

    FactoryBot.create(:account_plan, issuer: @provider)
    FactoryBot.create(:application_plan, issuer: @provider.default_service)
    FactoryBot.create(:service_plan, issuer: @provider.default_service)

    host! @provider.admin_domain
  end

  class AccessTokenTest < Admin::Api::AccountPlansTest
    test '#index without token' do
      get admin_api_account_plans_path(format: :xml)
      assert_response :forbidden
    end

    test '#index if member does not have the plans permission' do
      member = FactoryBot.create(:member, account: @provider, admin_sections: %w[])
      token = FactoryBot.create(:access_token, owner: member, scopes: 'account_management')

      get admin_api_account_plans_path(format: :xml), params: { access_token: token.value }
      assert_response :forbidden
    end

    test '#index if member has plans permission' do
      member = FactoryBot.create(:member, account: @provider, admin_sections: %w[partners plans])
      token = FactoryBot.create(:access_token, owner: member, scopes: 'account_management')

      get admin_api_account_plans_path(format: :xml), params: { access_token: token.value }
      assert_response :success
    end

    test '#index for provider admin' do
      admin = FactoryBot.create(:admin, account: @provider, admin_sections: [])
      token = FactoryBot.create(:access_token, owner: admin, scopes: 'account_management')

      get admin_api_account_plans_path(format: :xml), params: { access_token: token.value }
      assert_response :success
    end

    test '#index for master admin' do
      Account.any_instance.expects(:master?).returns(true).at_least_once
      admin = FactoryBot.create(:admin, account: @provider, admin_sections: [])
      token = FactoryBot.create(:access_token, owner: admin, scopes: 'account_management')

      get admin_api_account_plans_path(format: :xml), params: { access_token: token.value }
      assert_response :success
    end
  end

  class ProviderKeyTest < Admin::Api::AccountPlansTest
    def teardown
      @xml = nil
    end

    test 'index' do
      get admin_api_account_plans_path(format: :xml), params: provider_key_params
      assert_response :success
      assert_only_account_plans xml
    end

    test 'security wise: index is access denied in buyer side' do
      get admin_api_account_plans_path(format: :xml), params: provider_key_params
      assert_response :forbidden
    end

    pending_test 'apis can be behind the site_access code' do
      host! @provider.admin_domain
      Account.master.update_attribute :site_access_code, "123456"

      get admin_api_account_plans_path(format: :xml), params: provider_key_params

      assert @response.body =~ /Access code/
    end

    test 'show' do
      get admin_api_account_plan_path(@provider.account_plans.first, format: :xml), params: provider_key_params
      assert_response :success

      #TODO: move this to account_plan_test#to_xml
      assert_an_account_plan xml, @provider
    end

    test 'create' do
      assert_difference(-> { @provider.account_plans.count }) do
        post admin_api_account_plans_path(format: :xml), params: provider_key_params.merge({ name: 'awesome account plan', state_event: 'publish' })
        assert_response :success
      end

      assert_an_account_plan xml, @provider
      assert_equal xml.xpath('.//plan/name').children.first.to_s, 'awesome account plan'
      assert_equal xml.xpath('.//plan/state').children.first.to_s, 'published'
    end

    test 'update' do
      plan = FactoryBot.create(:account_plan, issuer: @provider, name: 'namy')

      put admin_api_account_plan_path(plan, format: :xml), params: provider_key_params.merge({ state_event: 'publish', name: 'new name' })
      assert_response :success

      assert_an_account_plan xml, @provider
      assert_equal xml.xpath('.//plan/name').children.first.to_s, 'new name'
      assert_equal xml.xpath('.//plan/state').children.first.to_s, 'published'
    end

    test 'default' do
      plan = FactoryBot.create(:account_plan, issuer: @provider, name: 'default plan')
      plan.publish!
      assert_not_equal @provider.default_account_plan, plan

      put default_admin_api_account_plan_path(plan, format: :xml, provider_key: @provider.api_key)
      assert_response :success

      assert_an_account_plan xml, @provider
      assert_not xml.xpath('.//plan[@default="true"]').empty?
      assert_equal @provider.reload.default_account_plan, plan
    end

    test 'hidden plan cannot be mark as default' do
      hidden_plan = FactoryBot.create(:account_plan, issuer: @provider, name: 'default plan', state: 'hidden')
      assert_not_equal @provider.default_account_plan, hidden_plan

      put default_admin_api_account_plan_path(hidden_plan, format: :xml, provider_key: @provider.api_key)
      assert_response :success
    end

    test 'destroy' do
      plan = FactoryBot.create(:account_plan, issuer: @provider)

      delete admin_api_account_plan_path(plan, format: :xml), params: provider_key_params.merge({ method: "_destroy" })
      assert_response :success

      assert_not @response.body.presence
      assert_raise ActiveRecord::RecordNotFound do
        plan.reload
      end
    end

    test 'destroy bought plan' do
      account_plan = FactoryBot.create(:account_plan, issuer: @provider)
      buyer = FactoryBot.create(:buyer_account, provider_account: @provider)
      buyer.buy! account_plan

      delete admin_api_account_plan_path(account_plan, format: :xml), params: provider_key_params.merge({ method: "_destroy" })
      assert_response :forbidden

      assert_xml_error(@response.body, "This account plan cannot be deleted")
    end

    private

    def provider_key_params
      { provider_key: @provider.api_key }
    end

    def xml
      @xml ||= Nokogiri::XML::Document.parse(@response.body)
    end
  end
end
