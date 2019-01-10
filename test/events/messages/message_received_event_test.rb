require 'test_helper'

class Messages::MessageReceivedEventTest < ActiveSupport::TestCase

  def test_create
    message   = FactoryBot.build_stubbed(:message)
    recipient = FactoryBot.build_stubbed(:received_message, message: message, receiver_id: 1)
    event     = Messages::MessageReceivedEvent.create(message, recipient)

    assert event
    assert_equal message, event.message
    assert_equal message.sender, event.sender
    assert_equal recipient, event.recipient
    assert_equal recipient.receiver, event.provider
    assert_equal recipient.receiver_id, event.metadata[:provider_id]
  end
end
