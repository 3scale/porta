require 'test_helper'

class MessageRecipientTest < ActiveSupport::TestCase

  def test_not_system_scope
    account        = FactoryBot.create(:simple_account)
    system_message = FactoryBot.create(:received_message, receiver: account)
    normal_message = FactoryBot.create(:received_message, receiver: account)

    system_message.message.update system_operation_id: 1
    normal_message.message.update system_operation_id: nil

    assert_equal 2, account.received_messages.count
    assert_equal [normal_message.id], account.received_messages.not_system.pluck(:id)
  end

  test 'using #latest be listed descending by created_at' do
    @outbox = []

    3.times do |i|
      travel_to((i+1).days.ago) do
        @outbox << deliver_message
      end
    end

    assert_equal @outbox, receiver.received_messages.latest.map { |mr| mr.message}
  end

  test 'reply has original subject prefixed with Re:' do
    assert_equal 'Re: Hello world', reply.subject
  end

  test 'reply has original body with quotation tags' do
    assert_equal "> First line.\n> \n> Second line.", reply.body
  end

  private

  def sender
    @sender ||= FactoryBot.create(:provider_account)
  end

  def receiver
    @receiver ||= FactoryBot.create(:buyer_account, provider_account: sender)
  end

  def reply
    deliver_message
    @message_recipient = receiver.received_messages.last
    @reply             = @message_recipient.reply
  end

  def deliver_message
    @message = sender.messages.build(to: receiver, subject: 'Hello world',
                                     body: "First line.\n\nSecond line.")
    @message.save!
    @message.deliver!
    @message
  end
end
