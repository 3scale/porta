# frozen_string_literal: true

require 'test_helper'

class SidekiqInitializerTest < ActiveSupport::TestCase
  test 'log job arguments' do
    logged = false
    invoice = FactoryBot.create(:invoice)

    Rails.logger.stubs(:info).with do |msg|
      next(true) unless /Enqueued InvoiceFriendlyIdWorker/.match?(msg)

      logged = msg.include?("with args: [#{invoice.id}]")
    end

    with_sidekiq do
      InvoiceFriendlyIdWorker.perform_async(invoice.id)
    end

    assert logged
  end
end
