# frozen_string_literal: true

require 'test_helper'

class NotificationsTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  def setup
    Logic::RollingUpdates.stubs(skipped?: true)
  end

  class MailDispatchRulesForAccountTest < NotificationsTest
    def setup
      super
      %w[plan_change weekly_reports daily_reports].each do |o|
        SystemOperation.for(o)
      end
      @account = FactoryBot.create(:account_without_users)
      @admin = FactoryBot.create(:admin, account: @account)
    end

    test 'have dispatch rule created when called for the first time' do
      assert_equal 0, @account.mail_dispatch_rules.count
      @account.dispatch_rule_for(SystemOperation.for(:weekly_reports)).dispatch?
      assert_equal 1, @account.mail_dispatch_rules.count
    end

    test 'not have dispatch rule duplicated' do
      @account.dispatch_rule_for(SystemOperation.for(:weekly_reports)).dispatch?
      assert_equal 1, @account.mail_dispatch_rules.count
      @account.dispatch_rule_for(SystemOperation.for(:weekly_reports)).dispatch?
      assert_equal 1, @account.mail_dispatch_rules.count
    end

    test 'have dispatch rules for reports set to false, by default' do
      assert_equal false, @account.dispatch_rule_for(SystemOperation.for(:weekly_reports)).dispatch?
      assert_equal false, @account.dispatch_rule_for(SystemOperation.for(:daily_reports)).dispatch?
    end

    test 'have dispatch rules for plan change set to true, by default' do
      assert_equal true, @account.dispatch_rule_for(SystemOperation.for(:plan_change)).dispatch?
    end
  end

  class ReceivingMessageWithMailDispatchRuleSetTest < NotificationsTest
    def setup
      super
      @operation = SystemOperation.for('plan_change')
      @buyer_sender = FactoryBot.create(:buyer_account)
      @provider_recipient = FactoryBot.create(:provider_account)

      @message = @buyer_sender.messages.build(to: @provider_recipient,
                                              subject: 'Plan Change',
                                              body: "Hello",
                                              system_operation: @operation)
    end

    test 'notify recipient by email when no rules exist and operation is not a report' do
      MailDispatchRule.delete_all

      @message.save!
      perform_enqueued_jobs(only: ActionMailer::DeliveryJob) { @message.deliver! }

      @message_recipient = @provider_recipient.received_messages.last
      assert_equal true, @message_recipient.notifiable?
    end

    test 'not notify recipient by email when no rules exist and operation is a report' do
      MailDispatchRule.delete_all
      @operation = SystemOperation.for('weekly_reports')
      @message.system_operation = @operation

      @message.save!
      perform_enqueued_jobs(only: ActionMailer::DeliveryJob) { @message.deliver! }

      @message_recipient = @provider_recipient.received_messages.last
      assert_equal false, @message_recipient.notifiable?
    end

    test 'notify recipient by email when rule for operation is set to true' do
      @rule = FactoryBot.create(:mail_dispatch_rule, account: @provider_recipient, dispatch: true, system_operation: @operation)

      assert_difference ActionMailer::Base.deliveries.method(:count) do
        @message.save!
        perform_enqueued_jobs(only: ActionMailer::DeliveryJob) { @message.deliver! }
      end

      @message_recipient = @provider_recipient.received_messages.last
      assert_equal true, @message_recipient.notifiable?
    end

    test 'NOT notify recipient when dispatch rule is set to true and notification preferences are enabled' do
      @rule = FactoryBot.create(:mail_dispatch_rule, account: @provider_recipient, dispatch: true, system_operation: @operation)

      Logic::RollingUpdates.stubs(skipped?: false, disabled?: true)

      assert_no_difference ActionMailer::Base.deliveries.method(:count) do
        @message.save!
        perform_enqueued_jobs(only: ActionMailer::DeliveryJob) { @message.deliver! }
      end
    end

    test 'NOT notify recipient when dispatch rule for operation is set to false' do
      @rule = FactoryBot.create(:mail_dispatch_rule, account: @provider_recipient, dispatch: false, system_operation: @operation)

      @message.save!
      perform_enqueued_jobs(only: ActionMailer::DeliveryJob) { @message.deliver! }

      @message_recipient = @provider_recipient.received_messages.last
      assert_equal @message_recipient.notifiable?, false
    end

    test 'notify recipient when operation has no corresponding system operation' do
      @message.update(system_operation: nil)
      @message.save!
      perform_enqueued_jobs(only: ActionMailer::DeliveryJob) { @message.deliver! }

      @message_recipient = @provider_recipient.received_messages.last
      assert_equal true, @message_recipient.notifiable?
    end
  end

  class TheMainTest < NotificationsTest
    def setup
      super
      ActionMailer::Base.deliveries = []

      @operation = SystemOperation.for('plan_change')
      @buyer_sender = FactoryBot.create(:buyer_account)
      @provider = FactoryBot.create(:provider_account)

      @message = Message.create!(sender: @buyer_sender,
                                 system_operation: @operation,
                                 to: [@provider],
                                 subject: 'hello',
                                 body: "what\'s up?")
      @provider_recipient = @message.recipients.first
    end

    test 'be sent to provider when dispatch rule is true' do
      @rule = FactoryBot.create(:mail_dispatch_rule, account: @provider, dispatch: true, system_operation: @operation)

      PostOffice.message_notification(@message, @provider_recipient).deliver_now
      @email = ActionMailer::Base.deliveries.last
      expected = [@provider.admins.first.email]
      assert_same_elements @email.bcc, expected
    end

    test 'be sent to provider when no corresponding system operation object exists' do
      SystemOperation.delete_all
      @message.update(system_operation: nil)
      @message.reload
      PostOffice.message_notification(@message, @provider_recipient).deliver_now
      @email = ActionMailer::Base.deliveries.last
      expected = [@provider.admins.first.email]
      assert_same_elements @email.bcc, expected
    end
  end

  class NotifyTest < NotificationsTest
    def setup
      super
      @system_operation = SystemOperation.for('plan_change')

      buyer = FactoryBot.create(:buyer_account)
      provider = FactoryBot.create(:provider_account)

      @message = Message.create!(sender: buyer,
                                 to: provider,
                                 subject: 'Changed plan',
                                 body: "plan has changed",
                                 system_operation: @system_operation)
    end

    test "have an operation attribute" do
      assert_equal @system_operation, @message.system_operation
    end
  end

  class ApplicationCreationTest < NotificationsTest
    def setup
      super
      @provider = FactoryBot.create(:provider_account)
      @admin = @provider.admins.first
      @admin.update(email: "provider-admin@example.com")

      @buyer = FactoryBot.create(:buyer_account, provider_account: @provider)
      @plan  = FactoryBot.create(:application_plan, issuer: @provider.default_service)
      ActionMailer::Base.deliveries.clear
    end

    test 'be notified' do
      perform_enqueued_jobs(only: ActionMailer::DeliveryJob) { @buyer.buy! @plan }
      assert_includes ActionMailer::Base.deliveries.last.bcc, @admin.email
    end

    test 'not be notified if mail_dispatch_rule denies it' do
      op = SystemOperation.create_with(name: 'New Application created').find_or_create_by!(ref: 'new_app')
      rule = @provider.mail_dispatch_rules.create!(system_operation: op, emails: @admin.email)
      rule.update(dispatch: false)

      perform_enqueued_jobs(only: ActionMailer::DeliveryJob) { @buyer.buy! @plan }

      assert ActionMailer::Base.deliveries.empty?
    end
  end

  class AccountSignupOnConfirmationTest < NotificationsTest
    def setup
      super
      @provider = FactoryBot.create :provider_account
      @admin = @provider.admins.first
      @admin.update(email: "provider-admin@example.com")

      @buyer = FactoryBot.create(:buyer_account, provider_account: @provider)
      ActionMailer::Base.deliveries.clear

      op = SystemOperation.for("user_signup")
      @mail_rule = @provider.mail_dispatch_rules.create!(system_operation: op)
    end

    test 'notify admins' do
      @mail_rule.update(dispatch: true)

      perform_enqueued_jobs(only: ActionMailer::DeliveryJob) { @buyer.make_pending! }

      assert_includes ActionMailer::Base.deliveries.map(&:bcc).flatten, @admin.email
    end

    test 'not notify admins if mail_dispatch_rule denies it' do
      @mail_rule.update(dispatch: false)

      perform_enqueued_jobs(only: ActionMailer::DeliveryJob) { @buyer.make_pending! }

      assert_not_includes ActionMailer::Base.deliveries.map(&:bcc).flatten, @admin.email
    end
  end
end
