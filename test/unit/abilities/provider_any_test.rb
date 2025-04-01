# frozen_string_literal: true

require 'test_helper'

module Abilities

  class BaseTest < ActiveSupport::TestCase
    setup do
      @account = FactoryBot.create(:provider_account)
      @account.stubs(:provider_can_use?).with(any_parameters).returns(false)
      @user  = FactoryBot.create(:simple_user, account: @account)
    end

    attr_reader :user, :account

    private

    def ability
      Ability.new(user)
    end
  end

  class ProviderAnyTest < BaseTest

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

    test 'Cinstance/Application events can show if has :partners and access to the service if the event includes a service' do
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
  end

  class AccountRelatedEventTest < BaseTest
    setup do
      # @account has a service and a service plan
      @service = FactoryBot.create(:simple_service, account: @account)
      service_plan = FactoryBot.create(:simple_service_plan, issuer: @service)

      # There's a buyer for @account and it's subscribed to the service
      @buyer = FactoryBot.create(:buyer_account, provider_account: @account)
      @buyer_user = FactoryBot.create(:simple_user, account: @buyer)
      FactoryBot.create(:service_contract, plan: service_plan, user_account: @buyer)

      # Another buyer but not subscribed to any service
      @buyer_no_service =  FactoryBot.create(:buyer_account, provider_account: @account)
      @buyer_no_service_user = FactoryBot.create(:simple_user, account: @buyer_no_service)
    end

    test "member has :partners and access to all service can show AccountRelatedEvent when the event doesn't include a service" do
      user.member_permission_service_ids = nil # All services allowed
      user.member_permission_ids = [:partners]
      assert_can ability, :show, Accounts::AccountCreatedEvent.create(@buyer_no_service, @buyer_no_service_user)
    end

    test "admin can show AccountRelatedEvent when the event doesn't include a service" do
      admin = account.first_admin
      ability = Ability.new(admin)
      assert_can ability, :show, Accounts::AccountCreatedEvent.create(@buyer_no_service, @buyer_no_service_user)
    end

    test 'member has :partners and access to all services can show AccountRelatedEvent if the event includes a service' do
      user.member_permission_service_ids = nil
      user.member_permission_ids = [:partners]

      assert_can ability, :show, Accounts::AccountCreatedEvent.create(@buyer, @buyer_user)
    end

    test 'member has :partners and access to one service can show AccountRelatedEvent if the event includes that service' do
      user.member_permission_service_ids = [@service.id]
      user.member_permission_ids = [:partners]

      assert_can ability, :show, Accounts::AccountCreatedEvent.create(@buyer, @buyer_user)
    end

    test "member has :partners and access to a service can't show AccountRelatedEvent if the event includes another service" do
      another_service = FactoryBot.create(:simple_service, account: @account)
      user.member_permission_service_ids = [another_service.id]
      user.member_permission_ids = [:partners]

      assert_cannot ability, :show, Accounts::AccountCreatedEvent.create(@buyer, @buyer_user)
    end

    test "member has :partners and access to no service can't show AccountRelatedEvent if the event includes a service" do
      user.member_permission_service_ids = []
      user.member_permission_ids = [:partners]

      assert_cannot ability, :show, Accounts::AccountCreatedEvent.create(@buyer, @buyer_user)
    end

    test 'member has :partners and access to one service can show AccountRelatedEvent if the event includes that service among others' do
      another_service = FactoryBot.create(:simple_service, account: @account)
      service_plan = FactoryBot.create(:simple_service_plan, issuer: another_service)
      FactoryBot.create(:service_contract, plan: service_plan, user_account: @buyer)

      user.member_permission_service_ids = [another_service.id]
      user.member_permission_ids = [:partners]

      assert_can ability, :show, Accounts::AccountCreatedEvent.create(@buyer, @buyer_user)
    end
  end

  class ShowAlertRelatedEventTest < BaseTest
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
end
