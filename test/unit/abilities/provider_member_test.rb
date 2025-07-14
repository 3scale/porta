require 'test_helper'

module Abilities
  class ProviderMemberTest < ActiveSupport::TestCase
    def setup
      @account = FactoryBot.create(:simple_provider)
      @member  = FactoryBot.create(:simple_user, account: @account)
    end

    def test_buyer_users
      buyer      = FactoryBot.build_stubbed(:simple_buyer, provider_account: @account)
      buyer_user = FactoryBot.build_stubbed(:simple_user, account: buyer)
      actions    = %i(read update update_role destroy suspend unsuspend)

      @member.admin_sections = []
      @member.save!

      actions.each do |action|
        assert_cannot ability, action, buyer_user
      end

      @member.admin_sections = ['partners']
      @member.save!

      actions.each do |action|
        assert_can ability, action, buyer_user
      end
    end

    def test_events_according_the_service
      # service has to be stored in database, because ability depends on scope user.accessible_services
      service  = FactoryBot.create(:simple_service, account: @account)
      plan     = FactoryBot.build_stubbed(:simple_service_plan, issuer: service)
      contract = FactoryBot.build_stubbed(:simple_service_contract, plan: plan)
      event    = ServiceContracts::ServiceContractCreatedEvent.create(contract, @member)

      assert_cannot ability, :show, event

      @member.member_permission_ids = ['partners']
      assert_can ability, :show, event

      @member.member_permission_service_ids = []
      assert_cannot ability, :show, event

      @member.member_permission_service_ids = [service.id]
      assert_can ability, :show, event
    end

    def test_events_according_the_users_permissions
      # @account has a service and a service plan
      service  = FactoryBot.create(:simple_service, account: @account)
      service_plan     = FactoryBot.create(:simple_service_plan, issuer: service)

      # The provider user (not admin) has permissions over the service
      @member.member_permission_service_ids = [service.id]

      # There's a buyer for @account and it's subscribed to the service
      buyer = FactoryBot.create(:buyer_account, provider_account: @account)
      user  = FactoryBot.create(:simple_user, account: buyer)
      FactoryBot.create(:service_contract, plan: service_plan, user_account: buyer)

      # There's also an application plan and an application
      app_plan = FactoryBot.create(:simple_application_plan, issuer: service)
      app = FactoryBot.create(:cinstance, plan: app_plan, user_account: buyer)

      account_event = Accounts::AccountCreatedEvent.create(buyer, user)
      billing_event = Invoices::InvoicesToReviewEvent.create(@account)
      limit_alert   = FactoryBot.create(:limit_alert, cinstance: app)
      alert_event   = Alerts::LimitAlertReachedProviderEvent.create(limit_alert)

      assert_cannot ability, :show, billing_event
      assert_cannot ability, :show, account_event
      assert_cannot ability, :show, alert_event

      @member.member_permission_ids = ['finance']
      assert_can ability, :show, billing_event

      @member.member_permission_ids = ['partners']
      assert_can ability, :show, account_event

      @member.member_permission_ids = ['monitoring']
      assert_can ability, :show, alert_event
    end

    def test_services
      service_1 = FactoryBot.create(:simple_service)
      service_2 = FactoryBot.create(:simple_service, account: @account)
      service_3 = FactoryBot.create(:simple_service, account: @account)

      assert_cannot ability, :show, service_1, 'foreign service'
      assert_cannot ability, :show, service_2, 'no services allowed'
      assert_cannot ability, :show, service_3, 'no services allowed'

      @member.update(allowed_sections: ['plans'])

      assert_cannot ability, :show, service_1, 'foreign service'
      assert_can ability, :show, service_2, 'all services allowed by default'
      assert_can ability, :show, service_3, 'all services allowed by default'

      @member.update(allowed_service_ids: [service_1.id, service_2.id])

      assert_cannot ability, :show, service_1, 'foreign service'
      assert_can ability, :show, service_2, 'allowed service'
      assert_cannot ability, :show, service_3, 'not allowed service'

      # this is migration path for existing customers that don't have service permissions yet
      Logic::RollingUpdates.stubs(skipped?: true)

      @member.update(allowed_service_ids: nil)

      assert_cannot ability, :show, service_1, 'foreign service'
      assert_can ability, :show, service_2, 'all services allowed by default'
      assert_can ability, :show, service_3, 'all services allowed by default'

      @member.member_permissions.delete_all
      @member.reload

      assert_cannot ability, :show, service_1, 'foreign service'
      assert_cannot ability, :show, service_2, 'no services allowed'
      assert_cannot ability, :show, service_3, 'no services allowed'
    end

    def test_cinstances
      service_1 = FactoryBot.create(:simple_service)
      service_2 = FactoryBot.create(:simple_service, account: @account)
      service_3 = FactoryBot.create(:simple_service, account: @account)

      plan_1 = FactoryBot.create(:simple_application_plan, issuer: service_1)
      plan_2 = FactoryBot.create(:simple_application_plan, issuer: service_2)
      plan_3 = FactoryBot.create(:simple_application_plan, issuer: service_3)

      app_1 = FactoryBot.create(:simple_cinstance, plan: plan_1)
      app_2 = FactoryBot.create(:simple_cinstance, plan: plan_2)
      app_3 = FactoryBot.create(:simple_cinstance, plan: plan_3)

      assert_cannot ability, :show, app_1, 'foreign service'
      assert_cannot ability, :show, app_2, 'none services allowed'
      assert_cannot ability, :show, app_3, 'none services allowed'

      @member.member_permission_ids = [:partners]
      @member.member_permission_service_ids = [service_1.id, service_2.id]

      assert_equal service_1, app_1.service
      assert_equal service_2, app_2.service
      assert_equal service_3, app_3.service

      assert_cannot ability, :show, app_1, 'foreign service'
      assert_can ability, :show, app_2, 'allowed service'
      assert_cannot ability, :show, app_3, 'not allowed service'

      # this is migration path for existing customers that don't have service permissions yet
      Logic::RollingUpdates.stubs(skipped?: true)

      @member.member_permission_ids = [:partners]
      @member.member_permission_service_ids = nil

      assert_can ability, :show, app_2, 'allowed service'
      assert_can ability, :show, app_3, 'allowed service'
    end

    def test_plans
      assert_cannot ability, :manage, :plans

      @member.member_permission_service_ids = [42]
      assert_cannot ability, :manage, :plans

      @member.member_permission_ids = [:plans]
      assert_can ability, :manage, :plans
    end

    def test_partners
      @member.member_permission_ids = [:partners]
      rolling_updates_off
      assert_cannot ability, :update, @account

      rolling_update(:service_permissions, enabled: true)
      assert_can ability, :update, @account
    end

    def test_account
      assert_cannot ability, :manage, @account
    end

    def test_user
      assert_can ability, :manage, @member

      assert_cannot ability, :destroy, @member
      assert_cannot ability, :update_role, @member
    end

    def test_data_export
      assert_cannot ability, :export, :data
    end

    def test_billing
      ThreeScale.config.stubs(onpremises: true)
      invoice = FactoryBot.build_stubbed(:invoice, buyer_account_id: @account.id)

      @account.stubs(master?: true)

      assert_cannot ability, :manage, :credit_card
      assert_cannot ability, :read, invoice

      @account.unstub(:master?)
      assert_can ability, :manage, :credit_card
      assert_can ability, :read, invoice
    end

    def test_portal
      @member.stubs(admin_sections: [:portal])
      assert_can ability, :manage, :portal

      @member.stubs(admin_sections: [])
      assert_cannot ability, :manage, :portal
    end

    def test_index_services
      @member.stubs(admin_sections: [:plans])
      assert_can ability, :index, Service

      @member.stubs(admin_sections: [:policy_registry])
      assert_can ability, :index, Service

      @member.stubs(admin_sections: [:monitoring])
      assert_can ability, :index, Service

      @member.stubs(admin_sections: %i[portal settings])
      assert_cannot ability, :index, Service
    end

    %i[suspend resume].each do | action |
      previous_state = action == :suspend ? 'approved' : 'suspended'

      test "can #{action} a buyer if has :partners permission" do
        @member.member_permission_ids = [:partners]
        buyer = FactoryBot.create(:buyer_account, provider_account: @account, state: previous_state)

        assert_can ability, :suspend, buyer
      end

      test "can't #{action} a buyer if it doesn't have :partners permission" do
        buyer = FactoryBot.create(:buyer_account, provider_account: @account, state: previous_state)

        assert_cannot ability, :suspend, buyer
      end

      test "can't #{action} a buyer if it belongs to another provider" do
        @member.member_permission_ids = [:partners]
        buyer = FactoryBot.create(:buyer_account, state: previous_state)

        assert_cannot ability, :suspend, buyer
      end
    end

    private

    def ability
      Ability.new(@member)
    end
  end
end
