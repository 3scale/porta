# frozen_string_literal: true

require 'test_helper'

class MessageDecoratorTest < Draper::TestCase
  test '#sender is decorated' do
    message = FactoryBot.build_stubbed(:message)
    decorated_message_sender = message.decorate.sender

    assert_equal AccountDecorator, decorated_message_sender.class
    assert_equal message.sender.id, decorated_message_sender.id
  end

  test '#recipients are decorated' do
    receivers = FactoryBot.create_list(:simple_buyer, 2)
    message = FactoryBot.create(:message, to: receivers)

    decorated_message_recipients = message.decorate.recipients

    assert_same_elements message.recipients.map(&:id), decorated_message_recipients.map(&:id)
    assert decorated_message_recipients.all? { |recipient| recipient.is_a?(MessageRecipientDecorator) }
  end
end
