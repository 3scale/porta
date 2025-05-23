# frozen_string_literal: true

require 'test_helper'

class MessageObserverTest < ActiveSupport::TestCase
  fixtures :countries

  setup do
    @observer = MessageObserver.instance
    @buyer = FactoryBot.create(:buyer_account)
    @provider = @buyer.provider_account
    @service = @provider.first_service!
    @plan = FactoryBot.create(:application_plan, issuer: @service)
  end

  class OtherTest < MessageObserverTest
    test 'after_create after_destroy' do
      app_plan = FactoryBot.create(:application_plan, issuer: @service)
      contract = FactoryBot.build(:service_contract, plan: FactoryBot.create(:service_plan, issuer: @service))
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

    test 'plan changed' do
      contract = FactoryBot.create(:service_contract, plan: FactoryBot.create(:simple_service_plan, issuer: @service))

      ServiceContracts::ServiceContractPlanChangedEvent.expects(:create).once

      contract.change_plan! FactoryBot.create(:simple_service_plan, issuer: @service)

      cinstance = FactoryBot.create(:cinstance, service: @service)

      Cinstances::CinstancePlanChangedEvent.expects(:create).once
      ContractMessenger.expects(:plan_change_for_buyer).once.returns(mock(deliver: true))

      cinstance.change_plan! FactoryBot.create(:simple_application_plan, service: @service)
    end

    pending_test 'after_commit_on_destroy'
  end

  class AfterCreateTest < MessageObserverTest
    test "should publish the correct event" do
      @app_plan = FactoryBot.create(:application_plan, issuer: @service)
      @service_plan = FactoryBot.create(:service_plan, issuer: @service)

      @cinstance = contract(@app_plan)
      Applications::ApplicationCreatedEvent.expects(:create).with(@cinstance, nil)
      @cinstance.save!

      @service_contract = contract(@service_plan)
      ServiceContracts::ServiceContractCreatedEvent.expects(:create).with(@service_contract, nil)
      @service_contract.save!
    end

    test 'should call observer' do
      @contract = contract(@plan)
      @observer.expects(:after_create).with(@contract)
      @contract.save!
    end
  end

  class PlanRequiresApproval < MessageObserverTest
    setup do
      @plan.update(approval_required: true)
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

    test '#reject should not send message when provider is scheduled for deletion' do
      @contract.provider_account.schedule_for_deletion!
      Contract.transaction do
        @contract.reject! 'reason'
        CinstanceMessenger.expects(:reject).never
      end
    end
  end

  class PlanDoesNotRequireApproval < MessageObserverTest
    setup do
      @plan.update(approval_required: false)
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
    Object.new.tap do |msg|
      msg.expects(:deliver).returns(true)
    end
  end

  def contract(plan)
    # if you try to create from buyers association it will create only Contract and observers wont ran
    plan.contracts.build(user_account: @buyer)
  end
end
