# frozen_string_literal: true

require 'test_helper'

class InvoiceFriendlyIdWorkerTest < ActiveSupport::TestCase
  disable_transactional_fixtures!

  setup do
    provider_account = FactoryBot.create(:provider_with_billing)
    provider_account.billing_strategy.update_attribute(:numbering_period, 'yearly')

    Invoice.any_instance.stubs(set_friendly_id: true)

    FactoryBot.create(:invoice_counter, provider_account: provider_account, invoice_prefix: Time.now.year.to_s)
    @invoice = FactoryBot.create(:invoice, provider_account: provider_account)
  end

  test 'updates invoice friendly id' do
    assert_equal 'fix', @invoice.friendly_id

    InvoiceFriendlyIdWorker.new.perform(@invoice.id)
    assert_equal "#{Time.now.year}-00000001", @invoice.reload.friendly_id
  end

  test "it's idempotent" do
    InvoiceFriendlyIdWorker.new.perform(@invoice.id)
    assert_equal "#{Time.now.year}-00000001", @invoice.reload.friendly_id

    InvoiceFriendlyIdWorker.new.perform(@invoice.id)
    assert_equal "#{Time.now.year}-00000001", @invoice.reload.friendly_id
  end
end
