require 'test_helper'

class Messages::DestroyServiceTest < ActiveSupport::TestCase

  def setup
    @message  = FactoryBot.create(:received_message)
    @messages = MessageRecipient.where(id: @message.id)
  end

  def test_run_with_ids
    assert_equal false, @message.hidden?

    Messages::DeleteService.run!({
      account:           @message.receiver,
      association_class: MessageRecipient,
      ids:               [@message.id]
    })

    @message.reload

    assert_equal true, @message.hidden?
  end

  def test_run_delete_all
    assert_equal false, @message.hidden?

    Messages::DeleteService.run!({
      account:           @message.receiver,
      association_class: MessageRecipient,
      delete_all:        true
    })

    @message.reload

    assert_equal true, @message.hidden?
  end

  def test_run_no_params
    assert_equal false, @message.hidden?

    Messages::DeleteService.run!({
      account:           @message.receiver,
      association_class: MessageRecipient,
    })

    @message.reload

    assert_equal false, @message.hidden?
  end
end
