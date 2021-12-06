# frozen_string_literal: true

require 'test_helper'

class CinstanceObserverTest < ActiveSupport::TestCase
  fixtures :countries

  setup do
    @plan = FactoryBot.create(:application_plan)
    @service = @plan.service

    @buyer = FactoryBot.create(:buyer_account)

    @provider = @plan.provider_account

    Logic::RollingUpdates.stubs(skipped?: true)
  end

  class NewCinstanceCreatedTest < CinstanceObserverTest
    setup do
      @cinstance = @buyer.buy!(@plan)
      @message = Message.last
    end

    test 'a message should be sent' do
      assert_not_nil @message
      assert @message.sent?
    end

    test 'a message should have the provider as a recipient' do
      assert_equal [@provider], @message.to
    end

    test 'a message should have the buyer as a sender' do
      assert_equal @buyer, @message.sender
    end

    test 'a message should have meaningful subject' do
      assert_match(/New Application submission/i, @message.subject)
    end

    test 'a message should contain service name' do
      assert_match(@service.name, @message.body)
    end

    test 'a message should contain plan name' do
      assert_match(@plan.name, @message.body)
    end

    test 'a message should contain buyer name' do
      assert_match(@buyer.org_name, @message.body)
    end

    test 'a message should contain buyer email' do
      assert_match(@buyer.admins.first.email, @message.body)
    end
  end

  class NewCinstanceApprovalRequired < CinstanceObserverTest
    setup do
      @plan.update(approval_required: true)
      @cinstance = @buyer.buy!(@plan)
    end

    class PendingCinstanceTest < NewCinstanceApprovalRequired
      test 'a message should say that the cinstance needs approval' do
        assert_match(/requires you to approve/i, Message.last.body)
      end
    end

    class AcceptedCinstanceTest < NewCinstanceApprovalRequired
      setup do
        @cinstance.accept!
        @message = Message.last
      end

      test 'a message should be sent' do
        assert_not_nil @message
        assert @message.sent?
      end

      test 'a message should have the buyer as a recipient' do
        assert_equal [@buyer], @message.to
      end

      test 'a message should have meaningful subject' do
        assert_not_nil @message.subject
      end

      test 'a message should contain provider name' do
        assert_match(@provider.org_name, @message.body)
      end

      test 'a message should contain service name' do
        assert_match(@cinstance.service.name, @message.body)
      end

      test 'a message should contain plan name' do
        assert_match(@cinstance.plan.name, @message.body)
      end

      pending_test 'a message should contain link to cinstance details'
    end

    class RejectedCinstanceTest < NewCinstanceApprovalRequired
      setup do
        @cinstance.reject!('any reason')
        @message = Message.last
      end

      test 'a message should be sent' do
        assert_not_nil @message
        assert @message.sent?
      end
    end
  end

  class NewCinstanceApprovalNotRequired < CinstanceObserverTest
    setup do
      @plan.update(approval_required: false)
      @cinstance = @buyer.buy!(@plan)
    end

    test 'a message should not say that the cinstance needs approval' do
      assert_no_match(/requires your approval/i, Message.last.body)
    end

    test 'does not send accept message to buyer if plan does not require approval' do
      assert_no_difference '@buyer.received_messages.count' do
        @buyer.buy!(@plan)
      end
    end
  end

  class CinstanceCancelledTest < CinstanceObserverTest
    setup do
      @cinstance = @buyer.buy!(@plan)
      Message.destroy_all

      @cinstance.destroy
      assert @message = Message.last
    end

    test 'a message should be sent' do
      assert_not_nil @message
      assert @message.sent?
    end

    test 'a message should have the provider as a recipient' do
      assert_equal [@provider], @message.to
    end

    test 'a message should have the buyer as a sender' do
      assert_equal @buyer, @message.sender
    end

    test 'a message should have meaningful subject' do
      assert_not_nil @message.subject
    end

    test 'a message should contain service name' do
      assert_match(@service.name, @message.body)
    end

    test 'a message should contain plan name' do
      assert_match(@plan.name, @message.body)
    end

    test 'a message should contain buyer name' do
      assert_match(@buyer.org_name, @message.body)
    end
  end

  class CinstanceChangesPlanTest < CinstanceObserverTest
    setup do
      @cinstance = @buyer.buy!(@plan)
      @new_plan = FactoryBot.create( :application_plan, :issuer => @service)

      @cinstance.change_plan!(@new_plan)
      @cinstance.save!
    end

    class MessageToProviderTest < CinstanceChangesPlanTest
      setup do
        @message = @buyer.messages.last
      end

      test 'a message to provider should be sent' do
        assert_not_nil @message
        assert @message.sent?
      end

      test 'a message to provider should have the provider as a recipient' do
        assert_equal [@provider], @message.to
      end

      test 'a message to provider should contain service name' do
        assert_match(@service.name, @message.body)
      end

      test 'a message to provider should contain buyer name' do
        assert_match(@buyer.org_name, @message.body)
      end

      pending_test 'a message to provider should contain old plan name'

      test 'a message to provider should contain new plan name' do
        assert_match(@new_plan.name, @message.body)
      end
    end

    class MessageToBuyerTest < CinstanceChangesPlanTest
      setup do
        @message = @provider.messages.last
      end

      test 'a message to buyer should be sent' do
        assert_not_nil @message
        assert @message.sent?
      end

      test 'a message to buyer should have the buyer as a recipient' do
        assert_equal [@buyer], @message.to
      end

      test 'a message to buyer should contain new plan name' do
        assert_match(@new_plan.name, @message.body)
      end
    end
  end
end
