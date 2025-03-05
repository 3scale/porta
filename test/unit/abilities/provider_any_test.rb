# frozen_string_literal: true

require 'test_helper'

module Abilities
  class ProviderAnyTest < ActiveSupport::TestCase
    setup do
      @account = FactoryBot.create(:simple_provider)
      @account.stubs(:provider_can_use?).with(any_parameters).returns(false)
      @user  = FactoryBot.create(:simple_user, account: @account)
    end

    attr_reader :user, :account

    def test_policies_permissions_for_member
      account.expects(:provider_can_use?).with(:policy_registry).returns(true)

      assert_cannot ability, :manage, :policy_registry

      user.update allowed_sections: [:policy_registry]
      user.reload

      assert_can ability, :manage, :policy_registry
    end

    def test_policies_permissions_for_admin
      account.expects(:provider_can_use?).with(:policy_registry).returns(true)
      user.make_admin

      assert_can ability, :manage, :policy_registry
    end

    def test_policies_no_rolling_update
      account.expects(:provider_can_use?).with(:policy_registry).returns(false)

      assert_cannot ability, :manage, :policy_registry
    end

    def test_policies_not_tenant
      account.stubs(tenant?: false)

      assert_cannot ability, :manage, :policy_registry
    end

    test 'Cinstance/Application events can show if has :partners and access to the service if there is a service' do
      service = FactoryBot.create(:simple_service, account: @account)
      another_service = FactoryBot.create(:simple_service, account: @account)
      plan = FactoryBot.create(:simple_application_plan, issuer: service)
      cinstance = FactoryBot.create(:cinstance, plan: plan)
      cinstance_events = [
        Cinstances::CinstanceExpiredTrialEvent.create(cinstance), Cinstances::CinstanceCancellationEvent.create(cinstance),
        Cinstances::CinstancePlanChangedEvent.create(cinstance, user), Applications::ApplicationCreatedEvent.create(cinstance, user)
      ]

      cinstance_events.each do |cinstance_event|
        user.member_permission_ids = [:partners]
        user.member_permission_service_ids = []

        assert_cannot ability, :show, cinstance_event

        user.member_permission_service_ids = [another_service.id]

        assert_cannot ability, :show, cinstance_event

        user.member_permission_service_ids = [service.id]

        assert_can ability, :show, cinstance_event

        user.member_permission_ids = []

        assert_cannot ability, :show, cinstance_event
      end
    end

    test 'AccountRelatedEvent can show if has :partners and does not have a service' do
      assert_cannot ability, :show, Accounts::AccountCreatedEvent.create(account, user)

      user.member_permission_ids = [:partners]
      assert_can ability, :show, Accounts::AccountCreatedEvent.create(account, user)
    end

    class ShowAlertRelatedEventTest < ProviderAnyTest
      setup do
        service = FactoryBot.create(:simple_service, account: @account)
        plan = FactoryBot.create(:simple_application_plan, issuer: service)
        cinstance = FactoryBot.create(:cinstance, plan: plan)
        alert = FactoryBot.create(:limit_violation, cinstance: cinstance)
        @limit_violation_reached_provider_event = Alerts::LimitViolationReachedProviderEvent.create(alert)
      end

      attr_reader :limit_violation_reached_provider_event

      test 'cannot show AlertRelatedEvent when user does not have :monitoring' do
        assert_not user.has_permission? :monitoring
        assert_cannot ability, :show, limit_violation_reached_provider_event
      end

      # If the user has service-related permission, and no :services permission, it means it has access to all services
      test 'can show AlertRelatedEvent when user has :monitoring and the user has access to all services' do
        user.member_permission_ids = [:monitoring]
        assert user.has_permission? :monitoring

        assert_can ability, :show, limit_violation_reached_provider_event
      end

      test 'cannot show AlertRelatedEvent when user has :monitoring and does not have access to the service' do
        user.member_permission_ids = [:monitoring]
        user.member_permission_service_ids = []

        assert_cannot ability, :show, limit_violation_reached_provider_event
      end

      test 'can show AlertRelatedEvent when user has :monitoring and has access to the service' do
        user.member_permission_ids = [:monitoring]
        user.member_permission_service_ids = [limit_violation_reached_provider_event.service.id]

        assert_can ability, :show, limit_violation_reached_provider_event
      end
    end

    private

    def ability
      Ability.new(user)
    end
  end
end
