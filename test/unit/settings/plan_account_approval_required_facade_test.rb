# frozen_string_literal: true

require 'test_helper'

class Settings::PlanAccountApprovalRequiredFacadeTest < ActiveSupport::TestCase
  setup do
    @provider = FactoryBot.create(:provider_account)
    @plan = @provider.account_plans.default
    assert_equal [@plan], @provider.account_plans.to_a
  end

  attr_reader :provider, :plan

  def facade
    provider.reload.settings.account_approval_required_facade
  end

  test 'a single stock plan is editable' do
    assert_not plan.approval_required

    assert facade.editable?
    assert_not facade.locked?
    assert facade.update(true)
    assert plan.reload.approval_required
    assert facade.value
  end

  test 'customized plans are not counted, and the stock plan is written even when a customized plan is the default' do
    customized = FactoryBot.create(:buyer_account, provider_account: provider).buy!(plan).customize_plan!
    provider.update!(default_account_plan: customized)
    assert_not plan.approval_required
    assert_not customized.approval_required

    facade = self.facade
    assert facade.editable?
    assert facade.update(true)
    assert plan.reload.approval_required
    assert_not customized.reload.approval_required
  end

  test 'several stock plans are locked, show the default plan and ignore updates' do
    FactoryBot.create(:account_plan, issuer: provider, approval_required: false)
    plan.update!(approval_required: true)

    assert facade.locked?
    assert_not facade.editable?
    assert facade.value
    assert facade.update(false)
    assert plan.reload.approval_required
  end

  test 'several stock plans without a default show nil' do
    FactoryBot.create(:account_plan, issuer: provider)
    provider.update_column(:default_account_plan_id, nil)

    assert facade.locked?
    assert_nil facade.value
  end

  test 'no stock plans' do
    plan.destroy!

    assert_not facade.editable?
    assert_not facade.locked?
    assert_nil facade.value
    assert facade.update(true)
  end

  test 'loads at most two stock plans in one query' do
    FactoryBot.create_list(:account_plan, 2, issuer: provider)
    facade = self.facade

    assert_queries_count(1) { assert facade.locked? }
  end

  test 'uses already loaded account plans without a query' do
    provider.account_plans.load
    facade = provider.settings.account_approval_required_facade

    assert_no_queries { assert facade.editable? }
  end

  test 'update adds approval_required errors to the settings' do
    settings = provider.settings

    assert_not settings.account_approval_required_facade.update('')
    assert_equal ['is not included in the list'], settings.errors[:account_approval_required]
    assert settings.errors.added?(:account_approval_required, :inclusion, value: nil)
  end
end
