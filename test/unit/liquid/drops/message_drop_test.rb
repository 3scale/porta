require 'test_helper'

class Liquid::Drops::MessageDropTest < ActiveSupport::TestCase
  include Liquid

  def setup
    @message = FactoryBot.create(:message)
    @drop = Drops::Message.new(@message)
  end

  test '#id' do
    assert_equal @message.id, @drop.id
  end

  test '#state' do
    assert_equal 'unsent', @message.state
  end

  test '#url' do
    assert_match %r{/admin/messages/sent/([0-9])+}, @drop.url

    @message.stubs hidden_at: Time.now

    assert_match %r{/admin/messages/trash/([0-9])+}, @drop.url
  end

  test '#created_at' do
    assert_not_nil @drop.created_at
  end

  test '#body' do
    @message.update_attribute(:body, 'STUFF')
    assert_equal 'STUFF', @drop.body
  end

  test '#subject' do
    @message.update_attribute(:subject, 'SUBJECT')
    assert_equal 'SUBJECT', @drop.subject

    @message.update_attributes(body: 'b' * 20, subject: nil)
    assert_equal "#{'b' * 12}...", @drop.subject
  end
end
