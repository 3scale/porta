require 'test_helper'

class MessageObserverTest < ActiveSupport::TestCase

  disable_transactional_fixtures!

  fixtures :countries

  def setup
    @observer = MessageObserver.instance
    @buyer = Factory(:buyer_account)
    @provider = @buyer.provider_account
    @service = @provider.first_service!
    @plan = Factory(:application_plan, :issuer => @service)
  end

  def test_after_create_after_destroy
    app_plan  = FactoryBot.create(:application_plan, issuer: @service)
    contract  = FactoryBot.build(:service_contract)
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

    cinstance = FactoryBot.create(:cinstance)

    Cinstances::CinstancePlanChangedEvent.expects(:create).once
    ContractMessenger.expects(:plan_change).never

    cinstance.change_plan! FactoryBot.create(:simple_application_plan)

    Logic::RollingUpdates.stubs(skipped?: true)

    Cinstances::CinstancePlanChangedEvent.expects(:create).never
    ContractMessenger.expects(:plan_change).once.returns(mock(deliver: true))

    cinstance.change_plan! FactoryBot.create(:simple_application_plan)
  end

  context "after_commit_on_create" do
    should "call correct messenger" do
      @app_plan = Factory(:application_plan, :issuer => @service)
      @service_plan = Factory(:service_plan, :issuer => @service)

      @cinstance = contract(@app_plan)
      CinstanceMessenger.expects(:new_contract).with(@cinstance).returns(message)
      @cinstance.save!

      @service_contract = contract(@service_plan)
      ServiceContractMessenger.expects(:new_contract).with(@service_contract).returns(message)
      @service_contract.save!
    end

    should 'call observer' do
      @contract = contract(@plan)
      @observer.expects(:after_commit_on_create).with(@contract)
      @contract.save!
    end

    context "with account" do
      setup do
        @contract = contract(@plan)
      end

      should 'send message' do
        CinstanceMessenger.expects(:new_contract).with(@contract).returns(message)
        @contract.save!
      end

      context 'but without admin users' do
        setup do
          @buyer.admins.delete_all
        end

        should 'not send message' do
          CinstanceMessenger.expects(:new_contract).with(@cinstance).never
          @contract.save!
        end
      end

    end

    context 'without account' do
      setup do
        @cinstance = @plan.contracts.build
      end

      should 'not send message' do
        CinstanceMessenger.expects(:new_contract).with(@cinstance).never
        @cinstance.save!
      end
    end

  end

  context 'after_commit_on_destroy' do
    # TODO: implement destro tests
  end

  context 'after_approve' do

    context 'when plan requires approval' do
      setup do
        @plan.update_attribute :approval_required, true
        @contract = contract(@plan)
        @contract.save!
      end

      should 'send message' do
        Contract.transaction do
          @contract.accept!
          CinstanceMessenger.expects(:accept).with(@contract).returns(message)
        end
      end
    end

    context 'when plan doesnt require approval' do
      setup do
        @plan.update_attribute :approval_required, false
        @contract = contract(@plan)
      end

      should 'not send message' do
        CinstanceMessenger.expects(:accept).never
        @contract.save!
      end
    end

  end

  context 'after_reject' do

    context 'when plan requires approval' do
      setup do
        @plan.update_attribute :approval_required, true
        @contract = contract(@plan)
        @contract.save!
      end

      should 'send message' do
        Contract.transaction do
          @contract.reject! 'reason'
          CinstanceMessenger.expects(:reject).with(@contract).returns(message)
        end
      end
    end

    context 'when plan doesnt require approval' do
      setup do
        @plan.update_attribute :approval_required, false
        @contract = contract(@plan)
      end

      should 'not send message' do
        CinstanceMessenger.expects(:accept).never
        @contract.save! and @contract.reject!('reason')
      end
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
