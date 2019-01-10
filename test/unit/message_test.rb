require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class MessageTest < ActiveSupport::TestCase

  def test_not_system_for_provider
    provider = FactoryBot.create(:simple_provider)
    buyer    = FactoryBot.create(:simple_buyer, provider_account: provider)
    assert_equal 0, provider.messages.reload.not_system_for_provider.count

    Message.create!(sender: provider, to: [buyer], subject: '1', body: '1')
    assert_equal 1, provider.messages.reload.not_system_for_provider.count

    Message.create!(sender: provider, to: [buyer], subject: '1', body: '1', system_operation_id: 1)
    assert_equal 2, provider.messages.reload.not_system_for_provider.count

    Message.create!(sender: buyer, to: [provider], subject: '1', body: '1', system_operation_id: 1)
    assert_equal 2, provider.messages.reload.not_system_for_provider.count
  end

  def test_send_notifications
    provider = FactoryBot.create(:simple_provider)
    buyer    = FactoryBot.create(:simple_buyer, provider_account: provider)

    message  = Message.create!(sender: buyer, to: [provider], subject: '1', body: '2')
    Messages::MessageReceivedEvent.expects(:create).with(message, instance_of(MessageRecipient)).once
    message.deliver!

    message  = Message.create!(sender: provider, to: [buyer], subject: '1', body: '2')
    Messages::MessageReceivedEvent.expects(:create).with(message, instance_of(MessageRecipient)).never
    message.deliver!
  end

  test 'notifies recipients with email' do
    Logic::RollingUpdates.expects(skipped?: true).at_least_once

    sender = FactoryBot.create(:simple_provider)
    recipients = [ FactoryBot.create(:simple_buyer, provider_account: sender), FactoryBot.create(:simple_buyer, provider_account: sender)]

    recipients.each do |account|
      FactoryBot.create(:simple_admin, account: account)
    end

    ActionMailer::Base.deliveries = []

    message = Message.create!(:sender => sender, :to => recipients,
                              :subject => 'hello', :body => "what's up?")
    message.deliver!

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
    message = FactoryBot.create(:message)

    message.update_column(:subject, 'foobar')


    message.reload

    assert_equal 'foobar', message.subject
  end

  test 'can search by subject' do
    message = FactoryBot.create(:message, subject: 'some unique subject value')

    scope = Message.where(subject: message.subject)

    assert_equal [message], scope.to_a
    assert_equal 1,scope.count
  end

  test 'changes the from header if it s set in the provider' do
    Logic::RollingUpdates.expects(skipped?: true).at_least_once

    sender = FactoryBot.create(:provider_account, from_email: 'fake_email@example.com')

    recipients = [FactoryBot.create(:simple_buyer, provider_account: sender),
                  FactoryBot.create(:simple_buyer, provider_account: sender)]

    recipients.each do |account|
      FactoryBot.create(:simple_admin, account: account)
    end

    ActionMailer::Base.deliveries = []

    message = Message.create!(sender: sender, to: recipients,
                              subject: 'hello', body: "what's up?")
    message.deliver!

    assert delivery = ActionMailer::Base.deliveries.first

    assert_equal delivery['from'].value, sender.from_email
  end

  test "handles exceptions when delivering email" do
    skip 'really unnecessary test which does not work properly'

    Rails.env.stubs(:test?).returns(false)

    message = FactoryBot.create(:message)
    acc1, acc2 = FactoryBot.create(:simple_account), FactoryBot.create(:simple_account)

    message.to = acc1
    message.bcc = acc2

    message.save!
    PostOffice.expects(:message_notification).raises.twice
    System::ErrorReporting.expects(:report_error).twice
    message.deliver!
  end

  context 'by default' do
     setup do
       @message = Message.new
     end

     should 'not have a sender' do
       assert_nil @message.sender
     end

     should 'not have a subject' do
       assert @message.subject.blank?
     end

     should 'not have a body' do
       assert @message.body.blank?
     end

     should 'be in unsent state' do
       assert @message.unsent?
     end

     should 'not be hidden' do
       assert_nil @message.hidden_at
       assert !@message.hidden?
     end
  end

   context 'A message' do
     setup do
       @account = FactoryBot.create(:simple_account)
     end

     should 'be valid with a set of valid attributes' do
       message = FactoryBot.build(:message, :sender => @account)
       assert message.valid?
     end

     should 'require a sender_id' do
       message = FactoryBot.build(:message, :sender => nil)
       assert !message.valid?
       assert_equal 1, message.errors[:sender_id].size
     end

     should 'not require a subject' do
       message = FactoryBot.build(:message, :subject => nil, :sender => @account)
       assert message.valid?
     end

     should 'not require a body' do
       message = FactoryBot.build(:message, :body => nil, :sender => @account)
       assert message.valid?
     end
   end

   context 'message before being created' do
     setup do
       @sender   = FactoryBot.create(:simple_provider)
       @receiver = FactoryBot.create(:simple_buyer, provider_account: @sender)

       @message = FactoryBot.build(:message, sender: @sender)
     end

     should 'be enqueueable to background job queue' do
       @message.enqueue! :to => [ @receiver.id ]

       assert_equal 1, MessageWorker.jobs.size

       assert job = MessageWorker.jobs.first

       receivers, attributes = job['args']

       assert_equal({'to' => [@receiver.id]}, receivers)
       assert_equal @message.attributes, attributes
     end

     should 'not have any recipients' do
       assert @message.recipients.empty?
     end

     should 'not have any to receivers' do
       assert @message.to.empty?
     end

     should 'allow to receivers to be built' do
       @message.to(@receiver)
       assert_equal [@receiver], @message.to
     end

     should 'not_have_any_cc_receivers' do
       assert @message.cc.empty?
     end

     should 'allow_cc_receivers_to_be_built' do
       @message.cc(@receiver)
       assert_equal [@receiver], @message.cc
     end

     should 'not_have_any_bcc_receivers' do
       assert @message.bcc.empty?
     end

     should 'allow_bcc_receivers_to_be_built' do
       @message.bcc(@receiver)
       assert_equal [@receiver], @message.bcc
     end
   end

   context 'message after being created' do
     setup do
       @sender = FactoryBot.create(:simple_account)
       @receiver = FactoryBot.create(:simple_account)

       @message = FactoryBot.create(:message, sender: @sender)
     end

     should "not be enqued to background job queue" do
       @message.enqueue! :to => @receiver.id
       assert_equal 0, MessageWorker.jobs.size
     end

     should 'record when it was created' do
       assert_not_nil @message.created_at
     end

     should 'record when it was updated' do
       assert_not_nil @message.updated_at
     end

     should 'not have any recipients' do
       assert @message.recipients.empty?
     end

     should 'not have any to receivers' do
       assert @message.to.empty?
     end

     should 'allow to receivers to be built' do
       @message.to(@receiver)
       assert_equal [@receiver], @message.to
     end

     should 'not have any cc receivers' do
       assert @message.cc.empty?
     end

     should 'allow cc receivers to be built' do
       @message.cc(@receiver)
       assert_equal [@receiver], @message.cc
     end

     should 'not have any bcc receivers' do
       assert @message.bcc.empty?
     end

     should 'allow bcc receivers to be built' do
       @message.bcc(@receiver)
       assert_equal [@receiver], @message.bcc
     end
   end

   context 'message with recipients' do
     setup do
       sender = FactoryBot.create(:simple_provider)
       @erich = FactoryBot.create(:simple_buyer, provider_account: sender)
       @richard = FactoryBot.create(:simple_buyer, provider_account: sender)
       @ralph = FactoryBot.create(:simple_buyer, provider_account: sender)
       @message = FactoryBot.create(:message,
         :to => @erich,
         :cc => @richard,
         :bcc => @ralph,
         :sender => sender
                         )
     end

     should 'have recipients' do
       assert_equal 3, @message.recipients.count
     end

     should 'have to receivers' do
       assert_equal [@erich], @message.to
     end

     should 'have cc receivers' do
       assert_equal [@richard], @message.cc
     end

     should 'have bcc receivers' do
       assert_equal [@ralph], @message.bcc
     end

     should 'be able to deliver' do
       assert @message.deliver!
     end
   end

   context 'message hidden' do
     setup do
       @message = FactoryBot.create(:message, :sender => FactoryBot.create(:simple_account))
       @message.hide!
     end

     should 'record when it was hidden' do
       assert_not_nil @message.hidden_at
     end

     should 'be hidden' do
       assert @message.hidden?
     end
   end

   context 'message unhidden' do
     setup do
       @message = FactoryBot.create(:message, :sender => FactoryBot.create(:simple_account))
       @message.hide!
       @message.unhide!
     end

     should 'not have the recorded value when it was hidden' do
       assert_nil @message.hidden_at
     end

     should 'not be hidden' do
       refute @message.hidden?
     end
   end

   context 'message forwarded' do
     setup do
       @sender = FactoryBot.create(:simple_account)
       original_message = FactoryBot.create(:message,
         :subject => 'Hello',
         :body => 'How are you?',
         :sender => @sender,
         :to => FactoryBot.create(:simple_account),
         :cc => FactoryBot.create(:simple_account),
         :bcc => FactoryBot.create(:simple_account)
                                 )

       @message = original_message.forward
     end

     should 'be in unsent state' do
       assert @message.unsent?
     end

     should 'not be hidden' do
       refute @message.hidden?
     end

     should 'have original subject' do
       assert_equal 'Hello', @message.subject
     end

     should 'have original body' do
       assert_equal 'How are you?', @message.body
     end

     should 'use same sender' do
       assert_equal @sender, @message.sender
     end

     should 'not include to recipients' do
       assert @message.to.empty?
     end

     should 'not include cc recipients' do
       assert @message.cc.empty?
     end

     should 'not include bcc recipients' do
       assert @message.bcc.empty?
     end
   end

   context 'message replied' do
     setup do
       @admin = FactoryBot.create(:simple_account)
       @erich = FactoryBot.create(:simple_account)
       @richard = FactoryBot.create(:simple_account)
       @ralph = FactoryBot.create(:simple_account)

       original_message = FactoryBot.create(:message,
         :subject => 'Hello',
         :body => "This is first line.\n\nThis is second line.",
         :sender => @admin,
         :to => @erich,
         :cc => @richard,
         :bcc => @ralph
                                 )

       @message = original_message.reply
     end

     should 'be in unsent state' do
       assert @message.unsent?
     end

     should 'not be hidden' do
       refute @message.hidden?
     end

     should 'have original subject prefixed with Re:' do
       assert_equal 'Re: Hello', @message.subject
     end

     should 'have original body with quotation tags' do
       assert_equal "> This is first line.\n> \n> This is second line.", @message.body
     end

     should 'use same sender' do
       assert_equal @admin, @message.sender
     end

     should 'use same to recipients' do
       assert_equal [@erich], @message.to
     end

     should 'not include cc recipients' do
       assert @message.cc.empty?
     end

     should 'not include bcc recipients' do
       assert @message.bcc.empty?
     end
   end

   context 'message replied to all' do
     setup do
       @admin = FactoryBot.create(:simple_account)
       @erich = FactoryBot.create(:simple_account)
       @richard = FactoryBot.create(:simple_account)
       @ralph = FactoryBot.create(:simple_account)

       original_message = FactoryBot.create(:message,
         :subject => 'Hello',
         :body => 'How are you?',
         :sender => @admin,
         :to => @erich,
         :cc => @richard,
         :bcc => @ralph)

       @message = original_message.reply_to_all
     end

     should 'be in unsent state' do
       assert @message.unsent?
     end

     should 'not be hidden' do
       refute @message.hidden?
     end

     should 'have original subject prefixed with Re:' do
       assert_equal 'Re: Hello', @message.subject
     end

     should 'have original body with quotation tags' do
       assert_equal '> How are you?', @message.body
     end

     should 'use same sender' do
       assert_equal @admin, @message.sender
     end

     should 'use same to recipients' do
       assert_equal [@erich], @message.to
     end

     should 'use same cc recipients' do
       assert_equal [@richard], @message.cc
     end

     should 'use same bcc recipients' do
       assert_equal [@ralph], @message.bcc
     end
   end

   context 'message as a class' do
     setup do
       Message.delete_all
       @hidden_message = FactoryBot.create(:message, :hidden_at => Time.now,
         :sender => FactoryBot.create(:simple_account))
       @visible_message = FactoryBot.create(:message, :sender => FactoryBot.create(:simple_account))
     end

     should 'include only visible messages in visible scope' do
       assert_equal [@visible_message], Message.visible
     end
   end
end
