# frozen_string_literal: true

require 'test_helper'

class CinstanceObserverTest < ActiveSupport::TestCase
  fixtures :countries

  setup do
    @plan = FactoryBot.create(:application_plan)
    @service = @plan.service
    @provider = @plan.provider_account

    @buyer = FactoryBot.create(:buyer_account, provider_account: @provider)

    Logic::RollingUpdates.stubs(skipped?: true)
  end

  class NewCinstanceCreatedTest < CinstanceObserverTest
    setup do
      with_sidekiq do
        @cinstance = @buyer.buy!(@plan)
      end

      @notification = @provider.first_admin.notifications.find_by(system_name: :application_created)
      @mail = ActionMailer::Base.deliveries.select { _1.header["Event-ID"].to_s == @notification&.parent_event&.event_id }&.first
    end

    test 'a message should be sent' do
      assert_not_nil @notification
      assert @notification.delivered?
    end

    test 'a message should have the provider as a recipient' do
      assert_equal [@provider.first_admin.email], @mail.to
    end

    test 'a message should have meaningful subject' do
      assert_not_nil @mail.subject
    end

    test 'a message should contain service name' do
      assert_match(@service.name, @mail.text_part.body.to_s)
    end

    test 'a message should contain plan name' do
      assert_match(@plan.name, @mail.text_part.body.to_s)
    end

    test 'a message should contain buyer name' do
      assert_match(@buyer.org_name,@mail.text_part.body.to_s)
    end
  end

  class NewCinstanceApprovalRequired < CinstanceObserverTest
    setup do
      with_sidekiq do
        @plan.update(approval_required: true)
        @cinstance = @buyer.buy!(@plan)
      end

      @notification = @provider.first_admin.notifications.find_by(system_name: :application_created)
      @mail = ActionMailer::Base.deliveries.select { _1.header["Event-ID"].to_s == @notification&.parent_event&.event_id }&.first
    end

    class PendingCinstanceTest < NewCinstanceApprovalRequired
      test 'a message should say that the cinstance needs approval' do
        assert_match(/requires you to approve/i, @mail.text_part.body.to_s)
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
      with_sidekiq do
        @plan.update(approval_required: false)
        @cinstance = @buyer.buy!(@plan)
      end

      @notification = @provider.first_admin.notifications.find_by(system_name: :application_created)
      @mail = ActionMailer::Base.deliveries.select { _1.header["Event-ID"].to_s == @notification&.parent_event&.event_id }&.first
    end

    test 'a message should not say that the cinstance needs approval' do
      assert_no_match(/requires your approval/i, @mail.text_part.body.to_s)
    end

    test 'does not send accept message to buyer if plan does not require approval' do
      assert_no_difference '@buyer.received_messages.count' do
        @buyer.buy!(@plan)
      end
    end
  end

  class CinstanceCancelledTest < CinstanceObserverTest
    setup do
      with_sidekiq do
        cinstance = @buyer.buy!(@plan)
        cinstance.reload # to load the tenant_id set by the trigger
        cinstance.destroy
      end

      @notification = @provider.first_admin.notifications.find_by(system_name: :cinstance_cancellation)
      @mail = ActionMailer::Base.deliveries.select { _1.header["Event-ID"].to_s == @notification&.parent_event&.event_id }&.first
    end

    test 'cancel a message should be sent' do
      assert_not_nil @notification
      assert @notification.delivered?
    end

    test 'a message should have the provider as a recipient' do
      assert_equal [@provider.first_admin.email], @mail.to
    end

    test 'a message should have meaningful subject' do
      assert_not_nil @mail.subject
    end

    test 'a message should contain service name' do
      assert_match(@service.name, @mail.text_part.body.to_s)
    end

    test 'a message should contain plan name' do
      assert_match(@plan.name, @mail.text_part.body.to_s)
    end

    test 'a message should contain buyer name' do
      assert_match(@buyer.org_name, @mail.text_part.body.to_s)
    end
  end

  class CinstanceChangesPlanTest < CinstanceObserverTest
    setup do
      with_sidekiq do
        @cinstance = @buyer.buy!(@plan)
        @new_plan = FactoryBot.create( :application_plan, :issuer => @service)

        @cinstance.change_plan!(@new_plan)
        @cinstance.save!
      end
    end

    class MessageToProviderTest < CinstanceChangesPlanTest
      disable_transactional_fixtures!
      self.database_cleaner_strategy = :deletion
      self.database_cleaner_clean_with_strategy = :deletion

      setup do
        @notification = @provider.first_admin.notifications.find_by(system_name: :cinstance_plan_changed)
        @mail = ActionMailer::Base.deliveries.select { _1.header["Event-ID"].to_s == @notification&.parent_event&.event_id }&.first
      end

      test 'a message to provider should be sent' do
        assert_not_nil @notification
        assert @notification.delivered?
      end

      test 'a message to provider should have the provider as a recipient' do
        assert_equal [@provider.first_admin.email], @mail.to
      end

      test 'a message to provider should contain service name' do
        assert_match(@service.name, @mail.text_part.body.to_s)
      end

      test 'a message to provider should contain buyer name' do
        assert_match(@buyer.org_name, @mail.text_part.body.to_s)
      end

      pending_test 'a message to provider should contain old plan name'

      test 'a message to provider should contain new plan name' do
        assert_match(@new_plan.name, @mail.text_part.body.to_s)
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
