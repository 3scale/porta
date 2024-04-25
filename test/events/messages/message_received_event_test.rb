require 'test_helper'

class Messages::MessageReceivedEventTest < ActiveSupport::TestCase

  def test_create
    provider  = FactoryBot.build(:simple_provider, id: 1)
    message   = FactoryBot.build_stubbed(:message)
    recipient = FactoryBot.build_stubbed(:received_message, message: message, receiver: provider)
    event     = Messages::MessageReceivedEvent.create(message, recipient)

    assert event
    assert_equal message, event.message
    assert_equal message.sender, event.sender
    assert_equal recipient, event.recipient
    assert_equal recipient.receiver, event.provider
    assert_equal recipient.receiver_id, event.metadata[:provider_id]
  end
end
