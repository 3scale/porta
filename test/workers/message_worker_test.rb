# frozen_string_literal: true

require 'test_helper'

class MessageWorkerTest < ActiveSupport::TestCase
  attr_accessor :recipients, :attributes

  def setup
    provider = FactoryBot.create(:simple_provider)
    buyers = FactoryBot.create_list(:buyer_account, 3, provider_account: provider)
    @recipients =  { to: buyers.map { |b| b.admins.first.id } }
    @attributes = {
      subject: "API System: New Application submission",
      body: "Dear API Administrator,\n\n\n\nA new user john has signed up for your service API on plan Basic.",
      sender_id: provider.id,
      origin: 'web'
    }
  end

  test '#enqueue' do
    MessageWorker.enqueue(recipients, attributes)

    assert_equal 1, MessageWorker.jobs.size
  end

  test '#perform enqueued' do
    Sidekiq::Testing.inline! do
      Message.any_instance.expects(:deliver!)
      MessageWorker.enqueue(recipients, attributes)
    end
  end
end
