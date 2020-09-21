# frozen_string_literal: true

require 'test_helper'

class MessageRecipientDecoratorTest < Draper::TestCase
  test '#sender is decorated' do
    message = FactoryBot.create(:message, to: FactoryBot.create(:simple_buyer))
    decorated_message_recipient = message.recipients.first.decorate

    assert_equal AccountDecorator, decorated_message_recipient.sender.class
    assert_equal message.sender.id, decorated_message_recipient.sender.id
  end

  test '#receiver is decorated' do
    message = FactoryBot.create(:message, to: FactoryBot.create(:simple_buyer))
    decorated_message_recipient = message.recipients.first.decorate

    assert_equal message.recipients.first.receiver.id, decorated_message_recipient.receiver.id
    assert_instance_of AccountDecorator, decorated_message_recipient.receiver
  end
end
