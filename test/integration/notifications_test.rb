require 'test_helper'

class NotificationsTest < ActiveSupport::TestCase
  disable_transactional_fixtures!

  setup do
    Logic::RollingUpdates.stubs(skipped?: true)
  end

  context "mail dispatch rules for account" do
    setup do
      ['plan_change', 'weekly_reports', 'daily_reports'].each do |o|
        SystemOperation.for(o)
      end
      @account = Factory(:account_without_users)
      @admin = Factory(:admin, :account => @account)
    end

    should 'have dispatch rule created when called for the first time' do
      assert_equal 0, @account.mail_dispatch_rules.count
      @account.dispatch_rule_for(SystemOperation.for(:weekly_reports)).dispatch?
      assert_equal 1, @account.mail_dispatch_rules.count
    end

    should 'not have dispatch rule duplicated' do
      @account.dispatch_rule_for(SystemOperation.for(:weekly_reports)).dispatch?
      assert_equal 1, @account.mail_dispatch_rules.count
      @account.dispatch_rule_for(SystemOperation.for(:weekly_reports)).dispatch?
      assert_equal 1, @account.mail_dispatch_rules.count
    end

    should 'have dispatch rules for reports set to false, by default' do
      assert_equal false, @account.dispatch_rule_for(SystemOperation.for(:weekly_reports)).dispatch?
      assert_equal false, @account.dispatch_rule_for(SystemOperation.for(:daily_reports)).dispatch?
    end

    should 'have dispatch rules for plan change set to true, by default' do
      assert_equal true, @account.dispatch_rule_for(SystemOperation.for(:plan_change)).dispatch?
    end
  end

  context 'receiving a message with mail dispatch rule set' do
    setup do
      @operation = SystemOperation.for('plan_change')
      @buyer_sender = Factory :buyer_account
      @provider_recipient = Factory :provider_account

      @message = @buyer_sender.messages.build(
      :to => @provider_recipient,
      :subject => 'Plan Change',
      :body => "Hello",
      :system_operation => @operation)

    end

    should 'notify recipient by email when no rules exist and operation is not a report' do
      MailDispatchRule.delete_all

      @message.save!
      @message.deliver!

      @message_recipient = @provider_recipient.received_messages.last
      assert_equal true, @message_recipient.notifiable?

    end

    should 'not notify recipient by email when no rules exist and operation is a report' do
      MailDispatchRule.delete_all
      @operation = SystemOperation.for('weekly_reports')
      @message.system_operation = @operation

      @message.save!
      @message.deliver!

      @message_recipient = @provider_recipient.received_messages.last
      assert_equal false, @message_recipient.notifiable?

    end

    should 'notify recipient by email when rule for operation is set to true' do

      @rule = Factory :mail_dispatch_rule, :account => @provider_recipient, :dispatch => true, :system_operation => @operation

      assert_difference ActionMailer::Base.deliveries.method(:count) do
        @message.save!
        @message.deliver!
      end

      @message_recipient = @provider_recipient.received_messages.last
      assert_equal true, @message_recipient.notifiable?
    end

    should 'NOT notify recipient when dispatch rule is set to true and notification preferences are enabled' do
      @rule = FactoryBot.create(:mail_dispatch_rule, account: @provider_recipient, dispatch: true, system_operation: @operation)

      Logic::RollingUpdates.stubs(skipped?: false, disabled?: true)

      assert_no_difference ActionMailer::Base.deliveries.method(:count) do
        @message.save!
        @message.deliver!
      end
    end

    should 'NOT notify recipient when dispatch rule for operation is set to false' do
      @rule = Factory :mail_dispatch_rule, :account => @provider_recipient, :dispatch => false,  :system_operation => @operation

      @message.save!
      @message.deliver!

      @message_recipient = @provider_recipient.received_messages.last

      assert_equal @message_recipient.notifiable?, false
    end

    should 'notify recipient when operation has no corresponding system operation' do
      @message.update_attribute(:system_operation, nil)
      @message.save!
      @message.deliver!

      @message_recipient = @provider_recipient.received_messages.last

      assert_equal @message_recipient.notifiable?, true

    end
  end

  context 'The email' do
    setup do
      ActionMailer::Base.deliveries = []

      @operation = SystemOperation.for('plan_change')
      @buyer_sender = Factory :buyer_account
      @provider = Factory :provider_account

      @message = Message.create!(
        :sender => @buyer_sender,
        :system_operation => @operation,
        :to => [@provider],
        :subject => 'hello', :body => "what\'s up?")
      @provider_recipient = @message.recipients.first
    end


     should 'be sent to provider when dispatch rule is true' do
       @rule = Factory :mail_dispatch_rule, :account => @provider, :dispatch => true, :system_operation => @operation

       PostOffice.message_notification(@message, @provider_recipient).deliver_now
       @email = ActionMailer::Base.deliveries.last
       expected = [@provider.admins.first.email]
       assert_same_elements @email.bcc, expected
     end

    should 'be sent to provider when no corresponding system operation object exists' do
      SystemOperation.delete_all
      @message.update_attribute(:system_operation, nil)
      @message.reload
      PostOffice.message_notification(@message, @provider_recipient).deliver_now
      @email = ActionMailer::Base.deliveries.last
      expected = [@provider.admins.first.email]
      assert_same_elements @email.bcc, expected

    end

  end


  context 'notify' do

    setup do
      @system_operation = SystemOperation.for('plan_change')

      buyer = Factory :buyer_account
      provider = Factory :provider_account

      @message = Message.create!(
        :sender => buyer, :to => provider,
        :subject => 'Changed plan', :body => "plan has changed",
        :system_operation => @system_operation)

    end

    should "have an operation attribute" do
      assert_equal @system_operation, @message.system_operation
    end

  end

  context 'application creation' do
    setup do
      @provider = Factory :provider_account
      @admin = @provider.admins.first
      @admin.update_attribute :email, "provider-admin@example.com"

      @buyer = Factory :buyer_account, :provider_account => @provider
      @plan  = Factory :application_plan, :issuer => @provider.default_service
      ActionMailer::Base.deliveries.clear
    end

    should 'be notified' do
      @buyer.buy! @plan
      assert ActionMailer::Base.deliveries.last.bcc.include?(@admin.email)
    end

    should 'not be notified if mail_dispatch_rule denies it' do
      op = SystemOperation.create_with(name: 'New Application created').find_or_create_by!(ref: 'new_app')
      rule = @provider.mail_dispatch_rules.create! :system_operation => op, :emails => @admin.email
      rule.update_attribute :dispatch, false

      @buyer.buy! @plan

      assert ActionMailer::Base.deliveries.empty?
    end
  end

  context 'account signup on confirmation' do
    setup do
      @provider = Factory :provider_account
      @admin = @provider.admins.first
      @admin.update_attribute :email, "provider-admin@example.com"

      @buyer = Factory :buyer_account, :provider_account => @provider
      ActionMailer::Base.deliveries.clear

      op = SystemOperation.for("user_signup")
      @mail_rule = @provider.mail_dispatch_rules.create! :system_operation => op
    end

    should 'notify admins' do
      @mail_rule.update_attribute :dispatch, true

      @buyer.make_pending!

      assert ActionMailer::Base.deliveries.map(&:bcc).flatten.include?(@admin.email)
    end

    should 'not notify admins if mail_dispatch_rule denies it' do
      @mail_rule.update_attribute :dispatch, false

      @buyer.make_pending!

      assert false == ActionMailer::Base.deliveries.map(&:bcc).flatten.include?(@admin.email)
    end

  end
end
