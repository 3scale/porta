# frozen_string_literal: true

require 'test_helper'

class Sites::UsageRulesControllerIntegrationTest < ActionDispatch::IntegrationTest
  def setup
    @provider = FactoryBot.create(:provider_account)
    login_provider @provider
    @settings = @provider.settings
  end

  attr_reader :provider, :settings

  test 'update account_approval_required when editable applies the value' do
    plan = provider.account_plans.default
    plan.update!(approval_required: false)

    put admin_site_usage_rules_path, params: { settings: { account_approval_required: '1' } }

    assert_redirected_to admin_site_settings_url
    assert plan.reload.approval_required
  end

  test 'update account_approval_required when not editable is ignored' do
    FactoryBot.create(:account_plan, issuer: provider)
    assert_not settings.approval_required_editable?

    plan = provider.account_plans.default
    plan.update!(approval_required: false)

    put admin_site_usage_rules_path, params: { settings: { account_approval_required: '1' } }

    assert_redirected_to admin_site_settings_url
    assert_not plan.reload.approval_required
  end

  test 'update account_approval_required with empty string is ignored' do
    plan = provider.account_plans.default
    plan.update!(approval_required: true)

    put admin_site_usage_rules_path, params: { settings: { account_approval_required: '' } }

    assert_redirected_to admin_site_settings_url
    assert plan.reload.approval_required
  end

  test 'update account_approval_required with nil is ignored' do
    plan = provider.account_plans.default
    plan.update!(approval_required: true)

    put admin_site_usage_rules_path, params: { settings: { account_approval_required: nil } }

    assert_redirected_to admin_site_settings_url
    assert plan.reload.approval_required
  end

  test 'update account_approval_required is not reset when param is absent' do
    plan = provider.account_plans.default
    plan.update!(approval_required: true)

    put admin_site_usage_rules_path, params: { settings: { signups_enabled: '0' } }

    assert_redirected_to admin_site_settings_url
    assert plan.reload.approval_required
    assert_not settings.reload.signups_enabled
  end
end
