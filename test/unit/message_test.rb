# frozen_string_literal: true

require 'test_helper'

class MessageTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test '#not_system_for_provider' do
    provider = FactoryBot.create(:simple_provider)
    buyer = FactoryBot.create(:simple_buyer, provider_account: provider)
    assert_equal 0, provider.messages.reload.not_system_for_provider.count

    Message.create!(sender: provider, to: [buyer], subject: '1', body: '1')
    assert_equal 1, provider.messages.reload.not_system_for_provider.count

    Message.create!(sender: provider, to: [buyer], subject: '1', body: '1', system_operation_id: 1)
    assert_equal 2, provider.messages.reload.not_system_for_provider.count

    Message.create!(sender: buyer, to: [provider], subject: '1', body: '1', system_operation_id: 1)
    assert_equal 2, provider.messages.reload.not_system_for_provider.count
  end

  test 'send notifications' do
    provider = FactoryBot.create(:simple_provider)
    buyer = FactoryBot.create(:simple_buyer, provider_account: provider)

    message = Message.create!(sender: buyer, to: [provider], subject: '1', body: '2')
    Messages::MessageReceivedEvent.expects(:create).with(message, instance_of(MessageRecipient)).once
    message.deliver!

    message = Message.create!(sender: provider, to: [buyer], subject: '1', body: '2')
    Messages::MessageReceivedEvent.expects(:create).with(message, instance_of(MessageRecipient)).never
    message.deliver!
  end

  test 'notifies recipients with email' do
    Logic::RollingUpdates.expects(skipped?: true).at_least_once

    sender = FactoryBot.create(:simple_provider)
    recipients = [FactoryBot.create(:simple_buyer, provider_account: sender), FactoryBot.create(:simple_buyer, provider_account: sender)]

    recipients.each do |account|
      FactoryBot.create(:simple_admin, account: account)
    end

    ActionMailer::Base.deliveries = []

    message = Message.create!(sender: sender, to: recipients,
                              subject: 'hello', body: "what's up?")
    perform_enqueued_jobs(only: ActionMailer::DeliveryJob) { message.deliver! }

    assert delivery = ActionMailer::Base.deliveries.first
    assert_equal delivery['from'].value, Rails.configuration.three_scale.noreply_email

    recipients.each do |recipient|
      email = ActionMailer::Base.deliveries.find do |email|
        email.bcc.include?(recipient.admins.first.email)
      end

      assert_not_nil email
    end
  end

  test 'keeps subject' do
    message = FactoryBot.create(:message, subject: 'foobar')
    assert_equal 'foobar', message.subject
  end

  test 'can search by subject' do
    message = FactoryBot.create(:message, subject: 'some unique subject value')

    scope = Message.where(subject: message.subject)

    assert_equal [message], scope.to_a
    assert_equal 1, scope.count
  end

  test 'changes the from header if it s set in the provider' do
    Logic::RollingUpdates.expects(skipped?: true).at_least_once

    sender = FactoryBot.create(:provider_account, from_email: 'fake_email@example.com')

    recipients = FactoryBot.create_list(:simple_buyer, 2, provider_account: sender)
    recipients.each { |account| FactoryBot.create(:simple_admin, account: account) }

    ActionMailer::Base.deliveries = []

    message = Message.create!(sender: sender, to: recipients, subject: 'hello', body: "what's up?")
    perform_enqueued_jobs(only: ActionMailer::DeliveryJob) { message.deliver! }

    assert delivery = ActionMailer::Base.deliveries.first
    assert_equal delivery['from'].value, sender.from_email
  end

  test "handles exceptions when delivering email" do
    skip 'really unnecessary test which does not work properly'

    Rails.env.stubs(:test?).returns(false)

    message = FactoryBot.create(:message)
    acc1, acc2 = FactoryBot.create_list(:simple_account, 2)

    message.to = acc1
    message.bcc = acc2

    message.save!
    PostOffice.expects(:message_notification).raises.twice
    System::ErrorReporting.expects(:report_error).twice
    message.deliver!
  end

  test 'not have a sender by default' do
    assert_nil Message.new.sender
  end

  test 'not have a subject by default' do
    assert Message.new.subject.blank?
  end

  test 'not have a body by default' do
    assert Message.new.body.blank?
  end

  test 'be in unsent state by default' do
    assert Message.new.unsent?
  end

  test 'not be hidden by default' do
    assert_nil Message.new.hidden_at
    assert_not Message.new.hidden?
  end

  test 'A message be valid with a set of valid attributes' do
    message = FactoryBot.build(:message, sender: FactoryBot.create(:simple_account))
    assert_valid message
  end

  test 'A message require a sender_id' do
    message = FactoryBot.build(:message, sender: nil)
    assert_not message.valid?
    assert_equal 1, message.errors[:sender_id].size
  end

  test 'A message require a subject' do
    message = FactoryBot.build(:message, subject: "I am subject", sender: FactoryBot.create(:simple_account))
    assert_valid message
  end

  test 'A message without require a subject is not valid' do
    message = FactoryBot.build(:message, subject: nil, sender: FactoryBot.create(:simple_account))
    assert_not message.valid?
    assert_includes message.errors[:subject], "can't be blank"
    assert_equal 1, message.errors[:subject].size
  end

  test 'A message not require a body' do
    message = FactoryBot.build(:message, body: nil, sender: FactoryBot.create(:simple_account))
    assert_valid message
  end

  test 'restore' do
    provider = FactoryBot.create(:simple_account)
    buyer = FactoryBot.create(:buyer_account, provider_account: provider)
    provider_sent_message = FactoryBot.create(:message, sender: provider)
    FactoryBot.create(:received_message, message: provider_sent_message, receiver: buyer)
    buyer_sent_message = FactoryBot.create(:message, sender: buyer)
    provider_received_message = FactoryBot.create(:received_message, message: buyer_sent_message, receiver: provider)

    [provider_sent_message, provider_received_message].each(&:hide!)

    provider_sent_message.restore_for!(provider)
    assert_not provider_sent_message.reload.hidden?

    buyer_sent_message.restore_for!(provider)
    assert_not provider_received_message.reload.hidden?
  end
end

class MessageBeforeBeingCreatedTest < ActiveSupport::TestCase
  def setup
    @sender = FactoryBot.create(:simple_provider)
    @receiver = FactoryBot.create(:simple_buyer, provider_account: @sender)

    @message = FactoryBot.build(:message, sender: @sender)
  end

  test 'message before being created be enqueueable to background job queue' do
    @message.enqueue! to: [@receiver.id]

    assert_equal 1, MessageWorker.jobs.size

    assert job = MessageWorker.jobs.first

    receivers, attributes = job['args']

    assert_equal({ 'to' => [@receiver.id] }, receivers)
    assert_equal @message.attributes, attributes
  end

  test 'message before being created not have any recipients' do
    assert_empty @message.recipients
  end

  test 'message before being created not have any to receivers' do
    assert_empty @message.to
  end

  test 'message before being created allow to receivers to be built' do
    @message.to(@receiver)
    assert_equal [@receiver], @message.to
  end

  test 'message before being created not_have_any_cc_receivers' do
    assert_empty @message.cc
  end

  test 'message before being created allow_cc_receivers_to_be_built' do
    @message.cc(@receiver)
    assert_equal [@receiver], @message.cc
  end

  test 'message before being created not_have_any_bcc_receivers' do
    assert_empty @message.bcc
  end

  test 'message before being created allow_bcc_receivers_to_be_built' do
    @message.bcc(@receiver)
    assert_equal [@receiver], @message.bcc
  end
end

class MessageAfterBeingCreatedTest < ActiveSupport::TestCase
  def setup
    @sender = FactoryBot.create(:simple_account)
    @receiver = FactoryBot.create(:simple_account)

    @message = FactoryBot.create(:message, sender: @sender)
  end

  test "not be enqued to background job queue" do
    @message.enqueue! to: @receiver.id
    assert_equal 0, MessageWorker.jobs.size
  end

  test 'record when it was created' do
    assert_not_nil @message.created_at
  end

  test 'record when it was updated' do
    assert_not_nil @message.updated_at
  end

  test 'not have any recipients' do
    assert_empty @message.recipients
  end

  test 'not have any to receivers' do
    assert_empty @message.to
  end

  test 'allow to receivers to be built' do
    @message.to(@receiver)
    assert_equal [@receiver], @message.to
  end

  test 'not have any cc receivers' do
    assert_empty @message.cc
  end

  test 'allow cc receivers to be built' do
    @message.cc(@receiver)
    assert_equal [@receiver], @message.cc
  end

  test 'not have any bcc receivers' do
    assert_empty @message.bcc
  end

  test 'allow bcc receivers to be built' do
    @message.bcc(@receiver)
    assert_equal [@receiver], @message.bcc
  end
end

class MessageWithRecipientsTest < ActiveSupport::TestCase
  def setup
    sender = FactoryBot.create(:simple_provider)
    @erich = FactoryBot.create(:simple_buyer, provider_account: sender)
    @richard = FactoryBot.create(:simple_buyer, provider_account: sender)
    @ralph = FactoryBot.create(:simple_buyer, provider_account: sender)
    @message = FactoryBot.create(:message, to: @erich,
                                           cc: @richard,
                                           bcc: @ralph,
                                           sender: sender )
  end

  test 'have recipients' do
    assert_equal 3, @message.recipients.count
  end

  test 'have to receivers' do
    assert_equal [@erich], @message.to
  end

  test 'have cc receivers' do
    assert_equal [@richard], @message.cc
  end

  test 'have bcc receivers' do
    assert_equal [@ralph], @message.bcc
  end

  test 'be able to deliver' do
    assert @message.deliver!
  end
end

class MessageHiddenTest < ActiveSupport::TestCase
  def setup
    @message = FactoryBot.create(:message, sender: FactoryBot.create(:simple_account))
    @message.hide!
  end

  test 'record when it was hidden' do
    assert_not_nil @message.hidden_at
  end

  test 'be hidden' do
    assert @message.hidden?
  end
end

class MessageUnhiddenTest < ActiveSupport::TestCase
  def setup
    @message = FactoryBot.create(:message, sender: FactoryBot.create(:simple_account))
    @message.hide!
    @message.unhide!
  end

  test 'not have the recorded value when it was hidden' do
    assert_nil @message.hidden_at
  end

  test 'not be hidden' do
    assert_not @message.hidden?
  end
end

class MessageForwardedTest < ActiveSupport::TestCase
  def setup
    @sender = FactoryBot.create(:simple_account)
    original_message = FactoryBot.create(:message, subject: 'Hello',
                                                   body: 'How are you?',
                                                   sender: @sender,
                                                   to: FactoryBot.create(:simple_account),
                                                   cc: FactoryBot.create(:simple_account),
                                                   bcc: FactoryBot.create(:simple_account))
    @message = original_message.forward
  end

  test 'be in unsent state' do
    assert @message.unsent?
  end

  test 'not be hidden' do
    assert_not @message.hidden?
  end

  test 'have original subject' do
    assert_equal 'Hello', @message.subject
  end

  test 'have original body' do
    assert_equal 'How are you?', @message.body
  end

  test 'use same sender' do
    assert_equal @sender, @message.sender
  end

  test 'not include to recipients' do
    assert_empty @message.to
  end

  test 'not include cc recipients' do
    assert_empty @message.cc
  end

  test 'not include bcc recipients' do
    assert_empty @message.bcc
  end
end

class MessageRepliedTest < ActiveSupport::TestCase
  def setup
    @admin = FactoryBot.create(:simple_account)
    @erich = FactoryBot.create(:simple_account)
    @richard = FactoryBot.create(:simple_account)
    @ralph = FactoryBot.create(:simple_account)
    original_message = FactoryBot.create(:message, subject: 'Hello',
                                                   body: "This is first line.\n\nThis is second line.",
                                                   sender: @admin,
                                                   to: @erich,
                                                   cc: @richard,
                                                   bcc: @ralph)
    @message = original_message.reply
  end

  test 'be in unsent state' do
    assert @message.unsent?
  end

  test 'not be hidden' do
    assert_not @message.hidden?
  end

  test 'have original subject prefixed with Re:' do
    assert_equal 'Re: Hello', @message.subject
  end

  test 'have original body with quotation tags' do
    assert_equal "> This is first line.\n> \n> This is second line.", @message.body
  end

  test 'use same sender' do
    assert_equal @admin, @message.sender
  end

  test 'use same to recipients' do
    assert_equal [@erich], @message.to
  end

  test 'not include cc recipients' do
    assert_empty @message.cc
  end

  test 'not include bcc recipients' do
    assert_empty @message.bcc
  end
end

class MessageRepliedToAllTest < ActiveSupport::TestCase
  def setup
    @admin = FactoryBot.create(:simple_account)
    @erich = FactoryBot.create(:simple_account)
    @richard = FactoryBot.create(:simple_account)
    @ralph = FactoryBot.create(:simple_account)
    original_message = FactoryBot.create(:message, subject: 'Hello',
                                                   body: 'How are you?',
                                                   sender: @admin,
                                                   to: @erich,
                                                   cc: @richard,
                                                   bcc: @ralph)
    @message = original_message.reply_to_all
  end

  test 'be in unsent state' do
    assert @message.unsent?
  end

  test 'not be hidden' do
    assert_not @message.hidden?
  end

  test 'have original subject prefixed with Re:' do
    assert_equal 'Re: Hello', @message.subject
  end

  test 'have original body with quotation tags' do
    assert_equal '> How are you?', @message.body
  end

  test 'use same sender' do
    assert_equal @admin, @message.sender
  end

  test 'use same to recipients' do
    assert_equal [@erich], @message.to
  end

  test 'use same cc recipients' do
    assert_equal [@richard], @message.cc
  end

  test 'use same bcc recipients' do
    assert_equal [@ralph], @message.bcc
  end
end

class MessageAsAClassTest < ActiveSupport::TestCase
  def setup
    Message.delete_all
    @hidden_message = FactoryBot.create(:message, hidden_at: Time.zone.now, sender: FactoryBot.create(:simple_account))
    @visible_message = FactoryBot.create(:message, sender: FactoryBot.create(:simple_account))
  end

  test 'include only visible messages in visible scope' do
    assert_equal [@visible_message], Message.visible
  end
end
