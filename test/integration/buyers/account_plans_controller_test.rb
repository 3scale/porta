# frozen_string_literal: true

require 'test_helper'

class Buyers::AccountPlansControllerTest < ActionDispatch::IntegrationTest
  setup do
    @provider = FactoryBot.create(:provider_account)
    provider.settings.allow_account_plans!
  end

  attr_reader :provider

  class ProviderMemberTest < self
    setup do
      @member = FactoryBot.create(:member, account: provider, member_permission_ids: ['partners'])
      member.activate!

      login!(provider, user: member)
    end

    attr_reader :member

    test 'masterize' do
      other_plan = FactoryBot.create(:account_plan, name: 'Other plan', state: 'published', provider: provider)

      post masterize_admin_buyers_account_plans_path, params: { id: other_plan.id }
      assert_response :forbidden

      member.member_permission_ids = ['plans']
      member.save!

      post masterize_admin_buyers_account_plans_path, params: { id: other_plan.id }
      assert_response :redirect
      assert_equal other_plan, provider.reload.default_account_plan

      post masterize_admin_buyers_account_plans_path
      assert_response :redirect
      assert_equal nil, provider.reload.default_account_plan

      post masterize_admin_buyers_account_plans_path, params: { id: 'foo' }
      assert_response :not_found
    end
  end
end
