# frozen_string_literal: true

require 'test_helper'

class InvoiceFriendlyIdSanitizationWorkerTest < ActiveSupport::TestCase
  disable_transactional_fixtures!

  setup do
    @provider_account = FactoryBot.create(:provider_with_billing)
    @provider_account.billing_strategy.update_attribute(:numbering_period, 'yearly')
    FactoryBot.create(:invoice_counter, provider_account: @provider_account, invoice_prefix: Time.now.year.to_s)

    Invoice.any_instance.stubs(set_friendly_id: true)
    FactoryBot.create_list(:invoice, 3, provider_account: @provider_account)

    @invoices = @provider_account.buyer_invoices
  end

  test 'updates invoice friendly id' do
    assert_equal ['fix'], @invoices.pluck(:friendly_id).uniq

    InvoiceFriendlyIdSanitizationWorker.new.perform(@provider_account.id)

    invoice_prefix = Time.now.year.to_s
    invoice_friendly_ids = (1..3).map { |i| "#{invoice_prefix}-#{"%08d" % i}" }
    assert_same_elements invoice_friendly_ids, @invoices.reload.pluck(:friendly_id)
  end

  test "does not affect other providers' invoices" do
    other_provider_account = FactoryBot.create(:provider_with_billing)
    other_provider_account.billing_strategy.update_attribute(:numbering_period, 'yearly')
    other_invoice = FactoryBot.create(:invoice, provider_account: other_provider_account)

    InvoiceFriendlyIdSanitizationWorker.new.perform(@provider_account.id)

    assert_not_includes ['fix'], @invoices.reload.pluck(:friendly_id)
    assert_equal 'fix', other_invoice.reload.friendly_id
  end
end
