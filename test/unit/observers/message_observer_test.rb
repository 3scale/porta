# frozen_string_literal: true

require 'test_helper'

class MessageObserverTest < ActiveSupport::TestCase
  fixtures :countries

  def setup
    @observer = MessageObserver.instance
    @buyer = FactoryBot.create(:buyer_account)
    @provider = @buyer.provider_account
    @service = @provider.first_service!
    @plan = FactoryBot.create(:application_plan, :issuer => @service)
  end

  class OtherTest < MessageObserverTest
    def test_after_create_after_destroy
      app_plan  = FactoryBot.create(:application_plan, issuer: @service)
      contract  = FactoryBot.build(:service_contract, plan: FactoryBot.create(:service_plan))
      cinstance = contract(app_plan)

      Applications::ApplicationCreatedEvent.expects(:create).once
      assert cinstance.save!

      ServiceContracts::ServiceContractCreatedEvent.expects(:create).once
      assert contract.save!

      Cinstances::CinstanceCancellationEvent.expects(:create).once
      assert cinstance.destroy!

      ServiceContracts::ServiceContractCancellationEvent.expects(:create).once
      assert contract.destroy!
    end

    def test_plan_changed
      contract = FactoryBot.create(:service_contract)

      ServiceContracts::ServiceContractPlanChangedEvent.expects(:create).once
      ContractMessenger.expects(:plan_change).never

      contract.change_plan! FactoryBot.create(:simple_service_plan)

      cinstance = FactoryBot.create(:cinstance, service: @service)

      Cinstances::CinstancePlanChangedEvent.expects(:create).once
      ContractMessenger.expects(:plan_change).never

      ContractMessenger.expects(:plan_change_for_buyer).once.returns(mock(deliver: true))

      cinstance.change_plan! FactoryBot.create(:simple_application_plan, service: @service)

      Logic::RollingUpdates.stubs(skipped?: true)

      Cinstances::CinstancePlanChangedEvent.expects(:create).never
      ContractMessenger.expects(:plan_change).once.returns(mock(deliver: true))

      ContractMessenger.expects(:plan_change_for_buyer).once.returns(mock(deliver: true))

      cinstance.change_plan! FactoryBot.create(:simple_application_plan, service: @service)
    end

    pending_test 'after_commit_on_destroy'
  end

  class AfterCommitOnCreateTest < MessageObserverTest
    test "should call correct messenger" do
      @app_plan = FactoryBot.create(:application_plan, :issuer => @service)
      @service_plan = FactoryBot.create(:service_plan, :issuer => @service)

      @cinstance = contract(@app_plan)
      CinstanceMessenger.expects(:new_contract).with(@cinstance).returns(message)
      @cinstance.save!

      @service_contract = contract(@service_plan)
      ServiceContractMessenger.expects(:new_contract).with(@service_contract).returns(message)
      @service_contract.save!
    end

    test 'should call observer' do
      @contract = contract(@plan)
      @observer.expects(:after_commit_on_create).with(@contract)
      @contract.save!
    end

    test 'with account it should send message' do
      @contract = contract(@plan)
      CinstanceMessenger.expects(:new_contract).with(@contract).returns(message)
      @contract.save!
    end

    test 'with account but without admin users it should not send message' do
      @contract = contract(@plan)
      @buyer.admins.delete_all
      CinstanceMessenger.expects(:new_contract).with(@cinstance).never
      @contract.save!
    end

    test 'without account it should not send message' do
      @cinstance = @plan.contracts.build
      CinstanceMessenger.expects(:new_contract).with(@cinstance).never
      @cinstance.save!
    end
  end

  class PlanRequiresApproval < MessageObserverTest
    def setup
      super
      @plan.update_attribute :approval_required, true
      @contract = contract(@plan)
      @contract.save!
    end

    test '#accept should send message' do
      Contract.transaction do
        @contract.accept!
        CinstanceMessenger.expects(:accept).with(@contract).returns(message)
      end
    end

    test '#reject should send message' do
      Contract.transaction do
        @contract.reject! 'reason'
        CinstanceMessenger.expects(:reject).with(@contract).returns(message)
      end
    end
  end

  class PlanDoesNotRequireApproval < MessageObserverTest
    def setup
      super
      @plan.update_attribute :approval_required, false
      @contract = contract(@plan)
    end

    test '#accept should not send message' do
      CinstanceMessenger.expects(:accept).never
      @contract.save!
    end

    test '#reject should not send message' do
      CinstanceMessenger.expects(:accept).never
      @contract.save! and @contract.reject!('reason')
    end
  end

  private

  def message
    mock 'message' do
      expects(:deliver).returns(true)
    end
  end

  def contract(plan)
    # if you try to create from buyers association it will create only Contract and observers wont ran
    plan.contracts.build :user_account => @buyer
  end
end
