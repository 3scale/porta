# frozen_string_literal: true

require 'test_helper'

module Abilities
  class ProviderAnyTest < ActiveSupport::TestCase
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

    class ShowAlertRelatedEventTest < ProviderAnyTest
      setup do
        user.stubs(:has_permission?)

        cinstance = FactoryBot.build_stubbed(:simple_cinstance)
        alert = FactoryBot.build_stubbed(:limit_violation, cinstance: cinstance)
        @limit_violation_reached_provider_event = Alerts::LimitViolationReachedProviderEvent.create(alert)
      end

      attr_reader :limit_violation_reached_provider_event

      test 'cannot show AlertRelatedEvent when user does not have :monitoring' do
        user.expects(:has_permission?).with(:monitoring).returns(false)

        assert_cannot ability, :show, limit_violation_reached_provider_event
      end

      # This is related to the :service_permissions rolling update. Users created before it do not have the :services
      # section included in their member permissions, which grants them access to all services.
      test 'can show AlertRelatedEvent when user has :monitoring and the user has access to all services through the old permission system' do
        user.expects(:has_permission?).with(:monitoring).returns(true)

        assert_can ability, :show, limit_violation_reached_provider_event
      end

      test 'cannot show AlertRelatedEvent when user has :monitoring and does not have access to the service' do
        user.stubs(:has_permission?).with(:monitoring).returns(true)
        user.member_permissions.build(admin_section: :services, service_ids: [])

        assert_cannot ability, :show, limit_violation_reached_provider_event
      end

      test 'can show AlertRelatedEvent when user has :monitoring and has access to the service' do
        user.stubs(:has_permission?).with(:monitoring).returns(true)
        user.member_permissions.build(
          admin_section: :services,
          service_ids: [limit_violation_reached_provider_event.service.id]
        )

        assert_can ability, :show, limit_violation_reached_provider_event
      end
    end

    private

    def ability
      Ability.new(user)
    end
  end
end
