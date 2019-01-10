require 'test_helper'

class Logic::PlanChangesTest < ActiveSupport::TestCase

  def setup
    Logic::RollingUpdates.expects(skipped?: true).at_least_once

    # TODO: use plain ruby objects and include the Logic::PlanChanges
    # into them
    @plan = FactoryBot.create(:application_plan, name: 'Old plan')
    @new_plan = FactoryBot.create(:application_plan, issuer: @plan.issuer, name: 'Better plan')
    @new_paid_plan = FactoryBot.create(:application_plan, issuer: @plan.issuer, name: 'Better plan', :cost_per_month => 3)
    @new_plan.publish!

    @app = FactoryBot.create(:cinstance, plan: @plan)
    ActionMailer::Base.deliveries = []
  end

  test '#plan_change_permission_warning - direct' do
    @plan.issuer.stubs(plan_change_permission: :direct)
    assert_equal 'Are you sure you want to change your plan?',
                 @app.plan_change_permission_warning
  end

  test '#plan_change_permission_warning - request' do
    @plan.issuer.stubs(plan_change_permission: :request)
    assert_equal 'Are you sure you want to request a plan change?',
                 @app.plan_change_permission_warning
  end

  test '#plan_change_permission_warning - credit card missing' do
    @plan.issuer.stubs(plan_change_permission: :credit_card)
    @app.user_account.stubs(:credit_card_stored? => false)
    assert_equal 'Are you sure you want to request a plan change?',
                 @app.plan_change_permission_warning
  end

  test '#plan_change_permission_warning - credit card present' do
    @plan.issuer.stubs(plan_change_permission: :credit_card)
    @app.user_account.stubs(:credit_card_stored? => true)
    assert_equal 'Are you sure you want to change your plan?',
                 @app.plan_change_permission_warning
  end

  test '#buyer_changes_plan! - :direct' do
    @plan.issuer.stubs(plan_change_permission: :direct)
    @app.buyer_changes_plan!(@new_plan)
    assert_equal 'Better plan', @app.plan.name
  end

  test '#buyer_changes_plan! - :request' do
    @plan.issuer.stubs(plan_change_permission: :request)
    @app.buyer_changes_plan!(@new_plan)
    assert_equal 'Old plan', @app.plan.name
    assert_email_requests_exist
  end

  test '#buyer_changes_plan! - :credit_card (missing)' do
    @plan.issuer.stubs(plan_change_permission: :credit_card)
    @app.user_account.stubs(:credit_card_stored? => false)

    @app.buyer_changes_plan!(@new_plan)

    assert_equal 'Old plan', @app.plan.name
    assert_email_requests_exist
  end

  test '#buyer_changes_plan! - :credit_card (present)' do
    @plan.issuer.stubs(plan_change_permission: :credit_card)
    @app.user_account.stubs(:credit_card_stored? => true)

    @app.buyer_changes_plan!(@new_plan)

    assert_equal 'Better plan', @app.plan.name
    assert_empty ActionMailer::Base.deliveries
  end

  test '#buyer_changes_plan! - :request_credit_card (present)' do
    @plan.issuer.stubs(plan_change_permission: :request_credit_card)
    @app.user_account.stubs(:credit_card_stored? => true)

    @app.buyer_changes_plan!(@new_plan)

    assert_equal 'Better plan', @app.plan.name
    assert_empty ActionMailer::Base.deliveries
  end

  test '#buyer_changes_plan! - :request_credit_card (missing) - plan.paid' do
    @plan.issuer.stubs(plan_change_permission: :request_credit_card)
    @app.user_account.stubs(:credit_card_stored? => false)

    msg = @app.buyer_changes_plan!(@new_paid_plan)

    assert_equal "Please enter your credit card before changing the plan.", msg
    assert_equal 'Old plan', @app.plan.name
    assert_empty ActionMailer::Base.deliveries
  end

  test '#buyer_changes_plan! - :request_credit_card (missing) - plan.free' do
    @plan.issuer.stubs(plan_change_permission: :request_credit_card)
    @app.user_account.stubs(:credit_card_stored? => false)

    msg = @app.buyer_changes_plan!(@new_plan)

    assert_equal "Plan change was successful.", msg
    assert_equal 'Better plan', @app.plan.name
    assert_empty ActionMailer::Base.deliveries
  end

  def test_request_plan_change_actions
    @plan.issuer.stubs(plan_change_permission: :request)

    Accounts::AccountPlanChangeRequestedEvent.expects(:create)

    assert @app.buyer_changes_plan!(FactoryBot.create(:account_plan))
  end

  def test_request_application_plan_change_action
    @plan.issuer.stubs(plan_change_permission: :request)

    Applications::ApplicationPlanChangeRequestedEvent.expects(:create)

    assert @app.buyer_changes_plan!(FactoryBot.create(:application_plan))
  end

  def test_request_service_plan_change_actions
    @plan.issuer.stubs(plan_change_permission: :request)

    Services::ServicePlanChangeRequestedEvent.expects(:create)

    assert @app.buyer_changes_plan!(FactoryBot.create(:service_plan))
  end

  private

  def assert_email_requests_exist
    assert_equal ActionMailer::Base.deliveries.map(&:subject),
                 ["API System: Plan change request", "Plan change request has been received"]
  end
end
