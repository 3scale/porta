# frozen_string_literal: true

require 'test_helper'

class Provider::Admin::ApplicationsControllerTest < ActionController::TestCase
  include WebHookTestHelpers

  setup do
    @plan = FactoryBot.create(:published_plan)
    @service = @plan.service
    @provider = @plan.service.account
    login_as(@provider.admins.first)
    host! @provider.self_domain
  end

  test 'update application' do
    @service.update_attribute :default_application_plan, @plan
    app = FactoryBot.create(:application_contract, plan: @plan)

    put :update, params: { id: app.id, cinstance: { name: 'whatever' } }
    assert_response :redirect
  end

  # Regression test of https://github.com/3scale/system/issues/1354
  #
  # TODO: this should be integration test
  #
  test 'change plan should correctly mark paid_until' do
    app = FactoryBot.create(:application_contract, plan: @plan, paid_until: Date.new(2001,1,10))
    app.update_attribute :trial_period_expires_at, nil
    new_plan = FactoryBot.create(:published_plan, issuer: @service, cost_per_month: 300)

    @provider.timezone = 'Mountain Time (US & Canada)'
    @provider.save!
    @provider.settings.allow_finance!
    @provider.reload.billing_strategy.update_attribute(:prepaid, true)

    Timecop.freeze(Date.new(2001,1,25)) do
      put :change_plan, params: { id: app.id, cinstance: { plan_id: new_plan.id } }
    end

    assert_response :redirect
    assert_equal app.reload.plan, new_plan
    assert_equal Date.new(2001,1,31), app.reload.paid_until.to_date
  end

  test 'change_plan should email provider with link to app page' do
    Logic::RollingUpdates.expects(skipped?: true).at_least_once

    app = FactoryBot.create :application_contract, name: "desto mehr", plan: @plan
    new_plan = FactoryBot.create :published_plan, issuer: @service

    ActionMailer::Base.deliveries = []
    put :change_plan, params: { id: app.id, cinstance: { plan_id: new_plan.id } }

    assert_equal app.reload.plan, new_plan
    assert mail = ActionMailer::Base.deliveries.first, 'missing email'
    assert_match provider_admin_application_url(app, host: @provider.self_domain), mail.body.to_s
  end

  #regression test for https://github.com/3scale/system/issues/1889
  test 'change plan should work even when cinstance misses description' do
    app = FactoryBot.create(:application_contract, plan: @plan, name: "app name", description: nil)
    new_plan = FactoryBot.create :published_plan, issuer: @service

    @provider.settings.allow_multiple_applications!
    @provider.settings.show_multiple_applications!

    put :change_plan, params: { id: app.id, cinstance: { plan_id: new_plan.id } }

    assert_response :redirect
    assert_equal app.reload.plan, new_plan
  end
end
