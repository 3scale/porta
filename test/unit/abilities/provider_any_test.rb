# frozen_string_literal: true

require 'test_helper'

class Abilities::ProviderAdminTest < ActiveSupport::TestCase
  setup do
    @account = Account.new
    @account.stubs(provider?: true)
    @account.stubs(:provider_can_use?).with(any_parameters).returns(false)
    @user = User.new({account: @account}, without_protection: true)
  end

  attr_reader :user, :account

  def test_policies_allowed
    account.expects(:provider_can_use?).with(:policy_registry).returns(true)
    account.stubs(tenant?: true)

    assert_can ability, :manage, :policy_registry
  end

  def test_policies_no_rolling_update
    account.expects(:provider_can_use?).with(:policy_registry).returns(false)
    account.stubs(tenant?: true)

    assert_cannot ability, :manage, :policy_registry
  end

  def test_policies_not_tenant
    account.stubs(tenant?: false)

    assert_cannot ability, :manage, :policy_registry
  end

  test 'Cinstance/Application events can show if has :partners and access to the service if there is a service' do
    cinstance = FactoryBot.create(:cinstance)
    service = cinstance.service
    cinstance_events = [
      Cinstances::CinstanceExpiredTrialEvent.create(cinstance), Cinstances::CinstanceCancellationEvent.create(cinstance),
      Cinstances::CinstancePlanChangedEvent.create(cinstance, user), Applications::ApplicationCreatedEvent.create(cinstance, user)
    ]

    user.stubs(:has_permission?)
    user.stubs(:has_access_to_service?)

    cinstance_events.each do |cinstance_event|
      user.expects(:has_permission?).with(:partners).returns(true)
      user.expects(:has_access_to_service?).with(service.id).returns(false)
      assert_cannot ability, :show, cinstance_event

      user.expects(:has_permission?).with(:partners).returns(false)
      user.stubs(:has_access_to_service?).returns(true)
      assert_cannot ability, :show, cinstance_event

      user.expects(:has_permission?).with(:partners).returns(true)
      user.expects(:has_access_to_service?).with(service.id).returns(true)
      assert_can ability, :show, cinstance_event
    end
  end

  test 'AccountRelatedEvent can show if has :partners and does not have a service' do
    user.stubs(:has_permission?)

    user.expects(:has_permission?).with(:partners).returns(true)
    assert_can ability, :show, Accounts::AccountCreatedEvent.create(account, user)

    user.expects(:has_permission?).with(:partners).returns(false)
    assert_cannot ability, :show, Accounts::AccountCreatedEvent.create(account, user)
  end

  private

  def ability
    Ability.new(user)
  end
end
