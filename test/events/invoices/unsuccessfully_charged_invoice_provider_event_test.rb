require 'test_helper'

class Invoices::UnsuccessfullyChargedInvoiceProviderEventTest < ActiveSupport::TestCase

  def test_create
    provider = FactoryBot.build(:simple_provider, id: 2)
    invoice = FactoryBot.build_stubbed(:invoice, id: 1, provider_account: provider, state: 'created')
    event   = Invoices::UnsuccessfullyChargedInvoiceProviderEvent.create(invoice)

    assert event
    assert_equal event.invoice, invoice
    assert_equal event.provider, invoice.provider_account
    assert_equal event.state, invoice.state
  end
end
