# frozen_string_literal: true

require 'test_helper'

# TODO: Please split this file. It is too huge and takes too long
# Finished in 170.63189s
# 87 tests, 160 assertions, 0 failures, 0 errors, 0 skips
class CinstanceTest < ActiveSupport::TestCase

  test 'deleted cinstance have #to_xml working' do
    @cinstance = FactoryBot.create(:cinstance)
    @cinstance.destroy
    assert @cinstance.to_xml
  end

  test "delete_all bought_cinstances of a provider" do
    provider = FactoryBot.create(:provider_account)
    provider.bought_cinstances.delete_all
  end

  test 'Cinstance.live_at returns cinstances live at given time' do
    cinstance_one = FactoryBot.create(:cinstance)
    cinstance_two = travel_to(1.year.ago) { FactoryBot.create(:cinstance) }

    assert_does_not_contain Cinstance.live_at(6.months.ago), cinstance_one
    assert_contains Cinstance.live_at(6.months.ago), cinstance_two
  end

  test 'Cinstance.live_at returns cinstances live in given period' do
    cinstance_one = FactoryBot.create(:cinstance)
    cinstance_two = travel_to(1.year.ago) { FactoryBot.create(:cinstance) }

    assert_does_not_contain Cinstance.live_at(100.years.ago..1.month.ago), cinstance_one
    assert_contains Cinstance.live_at(100.years.ago..1.month.ago), cinstance_two
  end

  test 'Cinstance.live returns live cinstances' do
    cinstance = travel_to(1.year.ago) { FactoryBot.create(:cinstance) }

    assert_contains Cinstance.live, cinstance
  end

  test 'Cinstance.live returns deprecated cinstances' do
    plan = FactoryBot.create(:application_plan, cancellation_period: 1.month)

    cinstance = travel_to(1.year.ago) { FactoryBot.create(:cinstance, plan: plan) }

    cinstance.deprecate!

    assert_contains Cinstance.live, cinstance
  end

  test 'Cinstance.live does not return suspended cinstances' do
    cinstance = travel_to(6.months.ago) { FactoryBot.create(:cinstance) }

    cinstance.suspend!

    assert_does_not_contain Cinstance.live, cinstance
  end

  test 'Cinstance.live does not return destroyed cinstances' do
    cinstance = travel_to(6.months.ago) { FactoryBot.create(:cinstance) }

    cinstance.destroy

    assert_does_not_contain Cinstance.live, cinstance
  end

  test '.active_since' do
    cinstances = FactoryBot.create_list(:cinstance, 2)
    cinstances.first.update(first_daily_traffic_at: 1.year.ago)
    cinstances.last.update(first_daily_traffic_at: 1.day.ago)
    assert_equal [cinstances.last.id], Cinstance.active_since(1.month.ago).pluck(:id)
  end

  test 'Cinstance.all returns non destroyed cinstanced' do
    cinstance = FactoryBot.create(:cinstance)
    assert_contains Cinstance.all, cinstance
  end

  test 'Cinstance.all does not return destroyed cinstances' do
    cinstance = FactoryBot.create(:cinstance)
    cinstance.destroy

    assert_does_not_contain Cinstance.all, cinstance
  end

  test 'Cinstance.bought_by returns only cinstances with given user_account' do
    buyer_account_one = FactoryBot.create(:buyer_account)
    buyer_account_two = FactoryBot.create(:buyer_account)

    cinstance_one = FactoryBot.create(:cinstance, user_account: buyer_account_one)
    cinstance_two = FactoryBot.create(:cinstance, user_account: buyer_account_two)

    assert_contains Cinstance.bought_by(buyer_account_one), cinstance_one
    assert_does_not_contain Cinstance.bought_by(buyer_account_one), cinstance_two
  end

  test 'Cinstance.by_state(:pending) returns only pending cinstances' do
    pending_cinstance = FactoryBot.create(:application, :as_pending)

    destroyed_pending_cinstance = FactoryBot.create(:application, :as_pending)
    travel_to(1.hour.ago) { destroyed_pending_cinstance.destroy }

    live_cinstance = FactoryBot.create(:cinstance)

    assert_contains         Cinstance.by_state(:pending), pending_cinstance
    assert_does_not_contain Cinstance.by_state(:pending), live_cinstance
    assert_does_not_contain Cinstance.by_state(:pending), destroyed_pending_cinstance
  end

  test 'Cinstance.by_state(:live) returns only live cinstances' do
    live_cinstance = FactoryBot.create(:cinstance)
    pending_cinstance = FactoryBot.create(:application, :as_pending)

    destroyed_live_cinstance = FactoryBot.create(:cinstance)
    travel_to(1.hour.ago) { destroyed_live_cinstance.destroy }

    assert_contains         Cinstance.by_state(:live), live_cinstance
    assert_does_not_contain Cinstance.by_state(:live), pending_cinstance
    assert_does_not_contain Cinstance.by_state(:live), destroyed_live_cinstance
  end

  test 'by_active_since returns cinstances based on first_daily_traffic_at' do
    days_to_time_format = ->(x) { x.days.ago.to_time.strftime("%Y-%m-%d") }

    app1 = FactoryBot.create(:cinstance, first_daily_traffic_at: 3.days.ago.to_time)
    app2 = FactoryBot.create(:cinstance, first_daily_traffic_at: 1.day.ago.to_time)

    assert_equal [app2], Cinstance.by_active_since(days_to_time_format.call(2))
    assert_equal [app1], Cinstance.by_inactive_since(days_to_time_format.call(2))

  end

  test 'there can be only one cinstance per plan and user_account if validate_plan_is_unique!' do
    plan = FactoryBot.create(:application_plan)
    buyer_account = FactoryBot.create(:buyer_account)
    buyer_account.buy!(plan)

    cinstance_two = buyer_account.buy(plan) # no bang!
    cinstance_two.validate_plan_is_unique!
    assert cinstance_two.invalid?
  end

  test 'there can be more cinstances per plan if they have different user_accounts' do
    plan = FactoryBot.create(:application_plan)
    buyer_account_one = FactoryBot.create(:buyer_account)
    buyer_account_two = FactoryBot.create(:buyer_account)

    buyer_account_one.buy!(plan)
    cinstance_two = buyer_account_two.buy(plan) # no bang!

    assert cinstance_two.valid?
  end

  test 'there can be other cinstance per plan and user_account if the first one was destroyed' do
    plan = FactoryBot.create(:application_plan)
    buyer_account = FactoryBot.create(:buyer_account)

    cinstance_one = buyer_account.buy!(plan)
    cinstance_one.destroy

    cinstance_two = buyer_account.buy(plan)
    assert cinstance_two.valid?
  end

  test 'Cinstance.find_by_user_key finds cinstance by valid user key' do
    cinstance = FactoryBot.create(:cinstance)
    assert_equal cinstance, Cinstance.find_by(user_key: cinstance.user_key)
  end

  test 'Cinstance.find_by_user_key returns nil on nil key' do
    FactoryBot.create(:cinstance) # puts something in the db to avoid false positives.
    assert_nil Cinstance.find_by(user_key: nil)
  end

  test 'Cinstance.find_by_user_key returns nil on invalid key' do
    FactoryBot.create(:cinstance)
    assert_nil Cinstance.find_by(user_key: 'bogus-key')
  end

  test 'Cinstance.find_by_user_key! finds cinstance by valid user key' do
    cinstance = FactoryBot.create(:cinstance)
    assert_equal cinstance, Cinstance.find_by!(user_key: cinstance.user_key)
  end

  test 'Cinstance.find_by_user_key! raises an exception on nil key' do
    FactoryBot.create(:cinstance) # puts something in the db to avoid false positives.

    assert_raise ActiveRecord::RecordNotFound do
      Cinstance.find_by!(user_key: nil)
    end
  end

  test 'Cinstance.find_by_user_key! raises an exception on invalid key' do
    FactoryBot.create(:cinstance)

    assert_raise ActiveRecord::RecordNotFound do
      Cinstance.find_by!(user_key: 'bogus-key')
    end
  end

  test 'Cinstance.latest returns latest five cinstances' do
    plan = FactoryBot.create(:application_plan)
    cinstances = []

    travel_to(1.month.ago) do
      6.times do
        travel_to(1.day.from_now)
        cinstances << FactoryBot.create(:cinstance, plan: plan)
      end
    end

    assert_equal([cinstances[5], cinstances[4], cinstances[3], cinstances[2], cinstances[1]],
                 plan.cinstances.latest)
  end

  test 'Cinstance#resume! transitions from suspended to live state' do
    cinstance = FactoryBot.create(:cinstance)
    cinstance.suspend!

    cinstance.resume!
    assert cinstance.live?
  end

  test 'Cinstance#live? returns false when cinstance is pending' do
    cinstance = FactoryBot.create(:application, :as_pending)
    assert_not cinstance.live?
  end

  test 'Cinstance#accept! transitions from pending to live state' do
    cinstance = FactoryBot.create(:application, :as_pending)

    cinstance.accept!
    assert cinstance.live?
  end

  test 'Cinstance#reject! destroys pending cinstance' do
    cinstance = FactoryBot.create(:application, :as_pending)

    cinstance.reject!('because whatever reason')
    assert_does_not_contain Cinstance.all, cinstance
  end

  test 'Cinstance#reject! sets rejection reason' do
    cinstance = FactoryBot.create(:application, :as_pending)
    cinstance.reject!('because whatever reason')

    assert_equal 'because whatever reason', cinstance.rejection_reason
  end

  test 'Cinstance#currency' do
    cinstance = FactoryBot.create(:cinstance)

    cinstance.provider_account.country.currency = 'EUR'
    assert_equal 'EUR', cinstance.currency

    cinstance.provider_account.country.currency = 'NZD'
    assert_equal 'NZD', cinstance.currency
  end

  test 'notify_about_expired_trial_periods' do
    FactoryBot.create(:cinstance)
    Cinstance.update_all(trial_period_expires_at: Time.zone.now)
    assert Cinstance.notify_about_expired_trial_periods
  end

  test 'with_trial_period_expired_or_accepted' do
    FactoryBot.create(:cinstance)
    Cinstance.update_all(trial_period_expires_at: Date.today)
    assert_equal Cinstance.with_trial_period_expired_or_accepted(Date.today).count, Cinstance.count
  end

  test 'with_trial_period_expired' do
    FactoryBot.create(:cinstance)
    Cinstance.update_all(trial_period_expires_at: Date.today)
    assert_equal Cinstance.with_trial_period_expired(Date.today).count, Cinstance.count
  end

  test 'Cinstance.notify_about_expired_trial_periods does not send anything if plan is free' do
    travel_to(Date.new(2009, 11, 4)) do
      provider_account = FactoryBot.create(:provider_account)
      plan = FactoryBot.create(:application_plan, issuer: provider_account.first_service!, trial_period_days: 30, cost_per_month: 0)
      FactoryBot.create(:cinstance, plan: plan)
    end

    travel_to(Date.new(2009, 11, 24)) do
      CinstanceMessenger.expects(:expired_trial_period_notification).never
      Cinstance.notify_about_expired_trial_periods
    end
  end

  test 'Cinstance generates user_key and provider_public_key when created' do
    cinstance = Cinstance.new(plan: FactoryBot.create(:application_plan),
                              user_account: FactoryBot.create(:buyer_account))
    cinstance.save!

    assert_not_nil cinstance.user_key
    assert_not_nil cinstance.provider_public_key
  end

  test 'sets and saves a custom user_key' do
    cinstance = FactoryBot.build(:cinstance)
    cinstance.user_key = "TEST_KEY"
    cinstance.save!

    assert_equal 'TEST_KEY', cinstance.user_key
  end

  test 'user_key has to be unique per provider account' do
    provider_account = FactoryBot.create(:provider_account)
    plan = FactoryBot.create(:application_plan, issuer: provider_account.first_service!)

    FactoryBot.create(:cinstance, plan: plan, user_key: 'foo')
    cinstance_two = FactoryBot.build(:cinstance, plan: plan, user_key: 'foo')

    assert cinstance_two.invalid?
    assert_match /has already been taken/, cinstance_two.errors[:user_key].to_s

    cinstance_two.user_key = 'bar'
    assert cinstance_two.valid?
  end

  test 'user_key may be duplicated per service' do
    Logic::RollingUpdates.stubs(enabled?: true)

    provider = FactoryBot.create(:provider_account)
    plan1 = FactoryBot.create(:application_plan, issuer: FactoryBot.create(:service, account: provider))
    plan2 = FactoryBot.create(:application_plan, issuer: FactoryBot.create(:service, account: provider))

    Rails.configuration.three_scale.rolling_updates.stubs(features: {duplicate_user_key: []})
    assert FactoryBot.create(:cinstance, plan: plan1, user_key: 'foo')
    assert FactoryBot.build(:cinstance, plan: plan2, user_key: 'foo').invalid?

    Rails.configuration.three_scale.rolling_updates.stubs(features: {duplicate_user_key: [provider.id]})
    assert FactoryBot.build(:cinstance, plan: plan2, user_key: 'foo').valid?
  end

  test 'user_key does not have to be unique if provider accounts are different' do
    provider_account_one = FactoryBot.create(:provider_account)
    plan_one = FactoryBot.create(:application_plan, issuer: provider_account_one.first_service!)

    provider_account_two = FactoryBot.create(:provider_account)
    plan_two = FactoryBot.create(:application_plan, issuer: provider_account_two.first_service!)

    FactoryBot.create(:cinstance, plan: plan_one, user_key: 'foo')
    cinstance_two = FactoryBot.build(:cinstance, plan: plan_two, user_key: 'foo')

    assert cinstance_two.valid?
  end

  test '#display_name returns #name if present' do
    cinstance = Cinstance.new(name: 'Cool stuff')

    assert_equal 'Cool stuff', cinstance.display_name
  end

  test '#display_name returns automatic name containing plan name if #name is blank' do
    plan = FactoryBot.create(:application_plan, name: 'Insane')
    cinstance = Cinstance.new(plan: plan)

    assert_equal 'Application on plan Insane', cinstance.display_name
  end

  test 'customize_plan! method do nothing if plan fails to customize' do
    cinstance = FactoryBot.create(:cinstance)
    app_plan = cinstance.plan

    app_plan.stubs(:customize).returns(ApplicationPlan.new)

    cinstance.customize_plan!

    assert_equal app_plan, cinstance.plan
    assert_not cinstance.plan.customized?
  end

  test 'change the plan to a customized one if on stock plan' do
    cinstance = FactoryBot.create(:cinstance)
    plan = cinstance.plan

    assert_difference 'plan.service.plans.count', 1 do
      cinstance.customize_plan!
    end

    assert_not_equal plan, cinstance.plan
    assert cinstance.plan.customized?
  end

  test 'not change anything if already on custom plan' do
    cinstance = FactoryBot.create(:cinstance)
    cinstance.customize_plan!
    plan = cinstance.plan

    assert_no_difference 'plan.service.plans.count' do
      cinstance.customize_plan!
    end

    assert_equal plan, cinstance.plan
  end

  test 'decustomize_plan! method change the plan back to the stock one' do
    cinstance = FactoryBot.create(:cinstance)
    stock_plan = cinstance.plan

    cinstance.customize_plan!
    custom_plan = cinstance.plan

    assert_difference 'stock_plan.service.plans.count', -1 do
      assert_no_difference 'Cinstance.count' do
        cinstance.decustomize_plan!
        cinstance.reload
      end
    end

    assert_not_equal custom_plan, cinstance.plan
    assert_equal stock_plan, cinstance.plan
    assert_not cinstance.plan.customized?
  end

  test "validate cinstance's service and cinstance's plan's service are the same" do
    cinstance = FactoryBot.create(:cinstance)

    other_service = FactoryBot.create(:service, account: cinstance.provider_account)
    other_plan_diff_service = FactoryBot.create(:application_plan, service: other_service, name: "other plan of different service")
    cinstance.plan = other_plan_diff_service
    assert cinstance.invalid?
    assert_includes cinstance.errors['plan'], 'not allowed in this context'

    other_plan_same_service = FactoryBot.build_stubbed(:application_plan, service: cinstance.service, name: "other plan of same service")
    cinstance.plan = other_plan_same_service
    assert cinstance.valid?
  end

  test 'fields and extra fields be' do
    assert FieldsDefinition.targets.include?("Cinstance")
  end

  test '.model_name.human is application' do
    assert_equal "Application", Cinstance.model_name.human
  end

  test 'user_key should validate user key' do
    cinstance = FactoryBot.create(:cinstance)

    assert cinstance.valid?

    cinstance.user_key = "you-&$#!!!"

    assert cinstance.invalid?
    assert cinstance.errors[:user_key].present?

    cinstance.user_key = "you-awesome-man"
    assert cinstance.valid?

    cinstance.user_key = "k"*256
    assert cinstance.valid?

    cinstance.user_key << "k"
    assert cinstance.invalid?
    assert cinstance.errors[:user_key].present?
  end

  test 'validate_plan_is_unique' do
    cinstance = Cinstance.new
    assert_not cinstance.validate_plan_is_unique?
    cinstance.expects(:plan_is_unique).never
    cinstance.save

    cinstance.validate_plan_is_unique!
    assert cinstance.validate_plan_is_unique?
    cinstance.expects(:plan_is_unique)
    cinstance.save
  end

  def test_available_application_plans_only_include_stock_plans_other_than_own
    buyer = FactoryBot.create(:buyer_account)
    application = FactoryBot.create(:cinstance, user_account: buyer)
    other_plan = FactoryBot.create(:application_plan, issuer: application.service)
    other_application = FactoryBot.create(:cinstance, user_account: buyer, plan: other_plan)
    other_application.customize_plan!

    assert_same_elements [other_plan], application.available_application_plans.to_a
  end

  test 'archive as deleted' do
    plan = FactoryBot.create(:application_plan)
    travel_to(Time.utc(2009, 12, 22)) { FactoryBot.create(:cinstance, plan: plan) }
    cinstance = plan.cinstances.last
    cinstance_id = cinstance.id

    assert_difference(DeletedObject.method(:count), +1) { cinstance.destroy! }
    deleted_object_entry = DeletedObject.last!
    assert_equal cinstance_id, deleted_object_entry.object_id
    assert_equal 'Contract', deleted_object_entry.object_type
    assert_equal plan.service.id, deleted_object_entry.owner_id
    assert_equal 'Service', deleted_object_entry.owner_type
  end

  class ApplicationIdUniquenessTest < ActiveSupport::TestCase
    attr_reader :provider, :service_one, :service_two, :plan_one, :plan_two, :app_one

    setup do
      @provider = FactoryBot.create(:provider_account)
      @service_one = provider.first_service!
      @service_two = FactoryBot.create(:service, account: provider)
      @plan_one = FactoryBot.create(:application_plan, issuer: service_one)
      @plan_two = FactoryBot.create(:application_plan, issuer: service_two)
      @app_one = FactoryBot.create(:cinstance, plan: plan_one, application_id: 'app1')
    end

    test 'when rolling updates are disabled' do
      FactoryBot.create(:cinstance, plan: plan_two, application_id: 'app2')

      dup = app_one.dup
      dup.user_key = 'fobar'

      assert_not dup.save
      assert dup.errors[:application_id].presence
    end

    test 'duplication is controlled by roling update' do
      Logic::RollingUpdates.stubs(enabled?: true)

      app_dup = FactoryBot.build(:cinstance, plan: plan_two, application_id: app_one.application_id)

      Rails.configuration.three_scale.rolling_updates.stubs(features: { duplicate_application_id: [] })
      assert_not app_dup.save
      assert app_dup.errors[:application_id].presence

      Rails.configuration.three_scale.rolling_updates.stubs(features: { duplicate_application_id: [provider.id] })
      assert app_dup.save
    end

    test 'duplication is allowed for enterprise customers' do
      Logic::RollingUpdates.stubs(enabled?: true)
      Rails.configuration.three_scale.rolling_updates.stubs(features: { duplicate_application_id: false })

      app_dup = FactoryBot.build(:cinstance, plan: plan_two, application_id: app_one.application_id)
      assert_not app_dup.save
      assert app_dup.errors[:application_id].presence

      provider.bought_cinstances.first.destroy!
      FactoryBot.create(:cinstance, user_account: provider, plan: FactoryBot.create(:application_plan, system_name: '2022_enterprise_3M', issuer: master_account.default_service))
      assert app_dup.save
    end
  end


  test 'buyer_alerts_enabled??' do
    app = Cinstance.new

    assert_not app.buyer_alerts_enabled?

    app.service = Service.new(notification_settings: { web_buyer: [100] })

    assert app.buyer_alerts_enabled?
  end

  test 'keys_limit' do
    app = Cinstance.new

    assert_equal 5, app.keys_limit

    app.service = Service.new(backend_version: 'oauth')

    assert_equal 1, app.keys_limit
  end

  test '.not_bought_by' do
    FactoryBot.create(:cinstance, service: master_account.default_service)

    expected_cinstance_ids = Cinstance.where.has { user_account_id != Account.master.id }.pluck(:id)
    assert_same_elements expected_cinstance_ids, Cinstance.not_bought_by(master_account).pluck(:id)
  end

  test '.by_plan_system_name' do
    id_cinstance_with_pro_plan = FactoryBot.create(:application_contract, plan: FactoryBot.create(:application_plan, system_name: 'pro')).id
    id_cinstance_with_enterprise_plan = FactoryBot.create(:application_contract, plan: FactoryBot.create(:application_plan, system_name: 'enterprise')).id
    id_cinstance_with_another_plan = FactoryBot.create(:application_contract, plan: FactoryBot.create(:application_plan, system_name: 'system_name_1')).id
    id_service_contract_with_enterprise_plan = FactoryBot.create(:service_contract, plan: FactoryBot.create(:service_plan, system_name: 'enterprise')).id

    ids_cinstances_enterprise = Cinstance.by_plan_system_name('enterprise').pluck(:id)
    assert_includes     ids_cinstances_enterprise, id_cinstance_with_enterprise_plan
    assert_not_includes ids_cinstances_enterprise, id_cinstance_with_pro_plan
    assert_not_includes ids_cinstances_enterprise, id_cinstance_with_another_plan
    assert_not_includes ids_cinstances_enterprise, id_service_contract_with_enterprise_plan

    ids_cinstances_by_plan_system_name = Cinstance.by_plan_system_name(%w[enterprise pro]).pluck(:id)
    assert_includes     ids_cinstances_by_plan_system_name, id_cinstance_with_enterprise_plan
    assert_includes     ids_cinstances_by_plan_system_name, id_cinstance_with_pro_plan
    assert_not_includes ids_cinstances_by_plan_system_name, id_cinstance_with_another_plan
    assert_not_includes ids_cinstances_by_plan_system_name, id_service_contract_with_enterprise_plan

    ids_cinstances_enterprise_like = Cinstance.by_plan_system_name('%rpris%').pluck(:id)
    assert_includes     ids_cinstances_enterprise_like, id_cinstance_with_enterprise_plan
    assert_not_includes ids_cinstances_enterprise_like, id_cinstance_with_pro_plan
    assert_not_includes ids_cinstances_enterprise_like, id_cinstance_with_another_plan
    assert_not_includes ids_cinstances_enterprise_like, id_service_contract_with_enterprise_plan

    ids_cinstances_like_list = Cinstance.by_plan_system_name(%w[%terpr% %pr%]).pluck(:id)
    assert_includes     ids_cinstances_like_list, id_cinstance_with_enterprise_plan
    assert_includes     ids_cinstances_like_list, id_cinstance_with_pro_plan
    assert_not_includes ids_cinstances_like_list, id_cinstance_with_another_plan
    assert_not_includes ids_cinstances_like_list, id_service_contract_with_enterprise_plan
  end

  test 'App ID can include special characters as defined in the RFC 6749' do
    generate_random_key_with_all_chars_of_rfc_6749 = -> { ("\x20".."\x7e").to_a.shuffle.join }
    cinstance = FactoryBot.build(:cinstance, application_id: (app_id = generate_random_key_with_all_chars_of_rfc_6749.call))

    assert cinstance.save
    assert app_id, cinstance.reload.application_id
  end

  test 'App ID length is validated to be between 4 and 255 characters' do
    cinstance = FactoryBot.build(:cinstance)

    cinstance.application_id = ''
    assert cinstance.invalid?

    cinstance.application_id = 'a' * 3
    assert cinstance.invalid?

    cinstance.application_id = 'a' * 4
    assert cinstance.valid?

    cinstance.application_id = 'a' * 255
    assert cinstance.valid?
  end
end

class OnCreationTest < ActiveSupport::TestCase
  def setup
    plan = FactoryBot.create(:application_plan, setup_fee: 42.42, trial_period_days: 3)
    travel_to(Time.zone.local(1942,1,1,15,20))
    @cinstance = Cinstance.create(plan: plan)
  end

  test 'set setup_fee and trial from plan' do
    assert_equal Time.zone.local(1942,1,4,15,20), @cinstance.trial_period_expires_at
    assert_equal 42.42, @cinstance.setup_fee
  end

  # TODO: DRY
  test 'be in live state' do
    cinstance = Cinstance.new(plan: FactoryBot.create(:application_plan), user_account: FactoryBot.create(:buyer_account))
    cinstance.save!

    assert_equal 'live', cinstance.state
  end

  # TODO: DRY
  test 'be created in pending state if service requires signup approval' do
    service = FactoryBot.create(:service)
    plan = FactoryBot.create(:application_plan, issuer: service, approval_required: true)

    cinstance = Cinstance.new(plan: plan, user_account: FactoryBot.create(:buyer_account))
    cinstance.save!

    assert cinstance.pending?
  end
end

class ValidationsTest < ActiveSupport::TestCase
  subject { FactoryBot.create(:cinstance) }

  should validate_presence_of(:plan)
  should validate_acceptance_of(:conditions).with_message(/you should agree/i)

  def setup
    @provider = FactoryBot.create :provider_account
    @service = FactoryBot.create :service, account: @provider
    plan = FactoryBot.create :application_plan, issuer: @service
    @cinstance = FactoryBot.build :cinstance, plan: plan
  end

  class NameValidationTest < ValidationsTest
    test 'not require name as default' do
      assert @cinstance.valid?
    end

    test 'provider has multi apps enabled: not require name' do
      @provider.settings.allow_multiple_applications!
      @provider.settings.show_multiple_applications!
      assert @cinstance.valid?
    end

    test 'provider has multi apps enabled: require name if a human interaction is happening' do
      @provider.settings.allow_multiple_applications!
      @provider.settings.show_multiple_applications!
      @cinstance.validate_human_edition!

      assert @cinstance.invalid?
      assert @cinstance.errors[:name].presence
    end
  end

  class DescriptionValidationTest < ValidationsTest
    test 'not require description as default' do
      assert @cinstance.valid?
    end

    test 'provider has multi apps enabled: not require description' do
      @provider.settings.allow_multiple_applications!
      @provider.settings.show_multiple_applications!
      assert @cinstance.valid?
    end

    test 'provider has multi apps enabled: require description if a human interaction is happening' do
      @provider.settings.allow_multiple_applications!
      @provider.settings.show_multiple_applications!
      @cinstance.validate_human_edition!

      assert @cinstance.invalid?
      assert @cinstance.errors[:description].presence
    end

    test 'service requires intentions: not require description' do
      @service.update(intentions_required: true)
      assert @cinstance.valid?
    end

    test 'service requires intentions: require description if a human interaction is happening' do
      @service.update(intentions_required: true)
      @cinstance.validate_human_edition!

      assert @cinstance.invalid?
      assert @cinstance.errors[:description].presence
    end
  end

  class PlanClassValidation < ValidationsTest
    test 'be valid with an application plan' do
      app_plan = FactoryBot.create(:application_plan)
      app_contract = Cinstance.new(plan: app_plan)

      assert app_contract.valid?
    end

    test 'not be valid with a service plan' do
      service_plan = FactoryBot.create(:service_plan)
      assert_raises(ActiveRecord::AssociationTypeMismatch) do
        Cinstance.new(plan: service_plan)
      end
    end

    test 'not be valid with an account plan' do
      account_plan = FactoryBot.create(:account_plan)
      assert_raises(ActiveRecord::AssociationTypeMismatch) do
        Cinstance.new(plan: account_plan)
      end
    end
  end
end

class SuspendTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  setup do
    @cinstance = FactoryBot.create(:cinstance)
  end

  test 'transition from live to suspended state' do
    @cinstance.suspend!

    assert @cinstance.suspended?
  end

  test 'message the provider' do
    old_mgs_count = Message.count

    @cinstance.suspend!

    assert_equal old_mgs_count+1, Message.count
    #TODO: write some message assertion helper?
    msg = Message.last
    assert_equal msg.sender, @cinstance.provider_account
    assert msg.subject.include? 'has been suspended'
  end

  test 'email the buyer if configured so' do
    FactoryBot.create(:mail_dispatch_rule, system_operation: SystemOperation.for('app_suspended'), account: @cinstance.provider_account)

    perform_enqueued_jobs(only: ActionMailer::MailDeliveryJob) { @cinstance.suspend! }

    #TODO: write some email assertion helper?
    assert mail = ActionMailer::Base.deliveries.last, 'missing email'
    assert mail.bcc.include? @cinstance.user_account.admins.first.email
    assert mail.subject.include? 'has been suspended'
    assert mail.body.to_s.include? 'has suspended'
  end
end

class ChangePlanTest < ActiveSupport::TestCase
  setup do
    service = FactoryBot.create(:service)
    stock = FactoryBot.create(:application_plan, issuer: service)
    @another_plan = FactoryBot.create(:application_plan, issuer: service, name: "another plan")

    @cinstance = FactoryBot.create(:cinstance, plan: stock)
    @cinstance.customize_plan!
    @custom = Plan.find @cinstance.plan.id
  end

  test 'delete custom plan' do
    @cinstance.change_plan! @another_plan
    assert_equal @another_plan.id, @cinstance.reload.plan_id

    assert_raises(ActiveRecord::RecordNotFound) { @custom.reload }
  end

  test 'cannot change to a plan of different service' do
    other_service = FactoryBot.create(:service, account: @cinstance.provider_account)
    other_plan = FactoryBot.create(:application_plan, service: other_service, name: "other plan")
    assert_not @cinstance.change_plan other_plan
    assert_includes @cinstance.errors['plan'], 'not allowed in this context'
  end

  test 'does not change plan to no plan at all' do
    previous_plan = @cinstance.plan
    assert_not @cinstance.change_plan nil
    assert_empty @cinstance.errors['plan']
    assert_equal previous_plan, @cinstance.reload.plan
  end
end

class WebHooksTest < ActiveSupport::TestCase
  include WebHookTestHelpers

  subject { @cinstance || FactoryBot.create(:cinstance) }

  setup do
    @buyer = FactoryBot.create :buyer_account
    @provider = @buyer.provider_account
    @user = @buyer.admins.first
    @app_plan = FactoryBot.create(:application_plan, issuer: @provider.services.first!)
  end

  test 'be pushed if the cinstance is created by user' do
    User.current = @user
    cinstance = Cinstance.new(plan: @app_plan, user_account: @buyer)

    fires_webhook(cinstance)

    cinstance.save!
  end

  test 'not be pushed if the cinstance was not created by user' do
    User.current = nil
    cinstance = Cinstance.new(plan: @app_plan, user_account: @buyer)

    fires_webhook.never
    cinstance.save!
  end

  test 'be pushed if the cinstance is updated by user' do
    cinstance = Cinstance.create!(plan: @app_plan, user_account: @buyer)

    User.current = @user
    fires_webhook(cinstance)

    cinstance.update(name: "changed")
  end

  test 'not be pushed if the cinstance is not updated by user' do
    User.current = nil
    cinstance = Cinstance.create!(plan: @app_plan, user_account: @buyer)

    fires_webhook.never
    cinstance.update(name: "changed")
  end

  test 'be pushed if user_key is updated by user' do
    cinstance = Cinstance.create!(plan: @app_plan, user_account: @buyer)

    User.current = @user
    fires_webhook(cinstance, 'user_key_updated')
    fires_webhook(cinstance, 'key_updated')
    cinstance.change_user_key!

  end

  test 'not be pushed if user_key is not updated by user' do
    User.current = nil
    cinstance = Cinstance.create!(plan: @app_plan, user_account: @buyer)

    fires_webhook.never
    cinstance.change_user_key!
  end

  test 'be pushed if plan is changed by user' do
    another_plan = FactoryBot.create(:application_plan, issuer: @buyer.provider_account.services.first, name: "another plan")
    @cinstance = Cinstance.create!(plan: @app_plan, user_account: @buyer)
    User.current = @user

    # this is because of BillingObserver#bill_variable_for_plan_changed is saving the old contract `paid_until`
    fires_webhook(@cinstance)
    fires_webhook(@cinstance, 'plan_changed')

    @cinstance.change_plan! another_plan
  end

  test 'not be pushed if plan is not changed by user' do
    another_plan = FactoryBot.create(:application_plan, issuer: @buyer.provider_account.services.first, name: "another plan")
    @cinstance = Cinstance.create!(plan: @app_plan, user_account: @buyer)
    User.current = nil

    fires_webhook.never
    @cinstance.change_plan! another_plan
  end

  test 'suspend event not be pushed if not done by user' do
    cinstance = FactoryBot.create(:cinstance, plan: @app_plan, user_account: @buyer)
    User.current = nil

    fires_webhook.never

    cinstance.suspend!
  end

  test 'suspend event be pushed if done by user' do
    cinstance = FactoryBot.create(:cinstance, plan: @app_plan, user_account: @buyer)
    provider_admin = @buyer.provider_account.admins.first
    User.current = provider_admin

    fires_webhook(cinstance, "suspended")

    cinstance.suspend!
  end
end

class KeysTest < ActiveSupport::TestCase
  test 'creating keys in backend is fired only when app is created' do
    app = FactoryBot.build(:cinstance)

    app.expects(:create_key_after_create?).returns(true)

    creation = sequence('creation')

    app.expects(:update_backend_application).in_sequence(creation)
    ThreeScale::Core::ApplicationKey.expects(:save).in_sequence(creation)

    BackendClient::ToggleBackend.enable_all!

    assert app.save!
    assert app.application_keys.presence

    app.expects(:create_key_after_create?).never
    app.expects(:create_first_key).never

    app.destroy
  end
end

class ApplicationUpdatedSavedEventTest < ActiveSupport::TestCase
  disable_transactional_fixtures!

  def setup
    @cinstance = FactoryBot.create(:cinstance)
  end

  attr_reader :cinstance

  test 'ApplicationUpdatedEvent is created after an update' do
    assert_difference(EventStore::Event.where(event_type: Applications::ApplicationUpdatedEvent.to_s).method(:count)) do
      cinstance.update!({ description: 'example description to update cinstance' })
    end
  end

  test 'ApplicationUpdatedEvent is not created after an update if the only changes are for first_traffic_at or first_daily_traffic_at' do
    assert_no_difference(EventStore::Event.where(event_type: Applications::ApplicationUpdatedEvent.to_s).method(:count)) do
      cinstance.update(first_traffic_at: 2.days.ago.round)
    end

    assert_no_difference(EventStore::Event.where(event_type: Applications::ApplicationUpdatedEvent.to_s).method(:count)) do
      cinstance.update(first_daily_traffic_at: 2.days.ago.round)
    end

    assert_no_difference(EventStore::Event.where(event_type: Applications::ApplicationUpdatedEvent.to_s).method(:count)) do
      cinstance.update!({ first_traffic_at: 1.day.ago.round, first_daily_traffic_at: 1.day.ago.round }, without_protection: true)
    end
  end

  test 'ApplicationUpdatedEvent is created after an update when there are updated traffic and non-traffic attributes' do
    assert_difference(EventStore::Event.where(event_type: Applications::ApplicationUpdatedEvent.to_s).method(:count)) do
      cinstance.update!({ name: 'mycinstance', first_traffic_at: 1.day.ago.round, first_daily_traffic_at: 1.day.ago.round }, without_protection: true)
    end
  end
end
