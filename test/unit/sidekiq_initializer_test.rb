# frozen_string_literal: true

require 'test_helper'
require 'sidekiq/testing'

class SidekiqInitializerTest < ActiveSupport::TestCase
  test 'log job arguments' do
    logged = false
    ActiveRecord::Base.transaction
    SphinxIndexationWorker.stubs(:perform_later)
    Rails.logger.stubs(:info).with do |msg|
      next(true) if msg.start_with?("[EventBroker] ")

      logged = msg =~ /^Failed to reprocess invoice logo for.*/
    end

    buyer = FactoryBot.create(:buyer_account)
    assert logged
    Testing.inline! do
      BillingWorker.enqueue_for_buyer(buyer, Time.zone.now)
    end
  end
end
