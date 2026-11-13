# frozen_string_literal: true

require 'test_helper'

class Sites::UsageRulesControllerIntegrationTest < ActionDispatch::IntegrationTest
  def setup
    @provider = FactoryBot.create(:provider_account)
    login_provider @provider
    @settings = @provider.settings
  end

  attr_reader :provider, :settings

  test 'update account_approval_required applies the value with a single account plan' do
    plan = provider.account_plans.default
    plan.update!(approval_required: false)

    put admin_site_usage_rules_path, params: { settings: { account_approval_required: '1' } }

    assert_redirected_to admin_site_settings_url
    assert plan.reload.approval_required
  end

  test 'update account_approval_required is ignored with multiple account plans' do
    FactoryBot.create(:account_plan, issuer: provider)
    assert_not settings.approval_required_editable?

    plan = provider.account_plans.default
    plan.update!(approval_required: false)

    put admin_site_usage_rules_path, params: { settings: { account_approval_required: '1' } }

    assert_redirected_to admin_site_settings_url
    assert_not plan.reload.approval_required
  end

  test 'update with blank account_approval_required saves nothing' do
    plan = provider.account_plans.default
    plan.update!(approval_required: true)
    assert settings.signups_enabled

    put admin_site_usage_rules_path, params: { settings: { account_approval_required: '', signups_enabled: '0' } }

    assert_response :success
    assert_equal I18n.t('sites.usage_rules.update.error'), flash[:danger]
    assert plan.reload.approval_required
    assert settings.reload.signups_enabled
  end

  test 'update with blank boolean setting saves nothing' do
    assert settings.signups_enabled

    put admin_site_usage_rules_path, params: { settings: { signups_enabled: '' } }

    assert_response :success
    assert_equal I18n.t('sites.usage_rules.update.error'), flash[:danger]
    assert settings.reload.signups_enabled
  end

  test 'update account_approval_required with an empty array is ignored' do
    plan = provider.account_plans.default
    plan.update!(approval_required: true)

    put admin_site_usage_rules_path, params: { settings: { account_approval_required: [] } }

    assert_redirected_to admin_site_settings_url
    assert plan.reload.approval_required
  end

  test 'update account_approval_required with a non-empty array is ignored' do
    plan = provider.account_plans.default
    plan.update!(approval_required: false)

    put admin_site_usage_rules_path, params: { settings: { account_approval_required: ['1'] } }

    assert_redirected_to admin_site_settings_url
    assert_not plan.reload.approval_required
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
