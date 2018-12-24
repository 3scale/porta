require 'test_helper'

class Invoices::InvoicesToReviewEventTest < ActiveSupport::TestCase

  def test_create
    provider = FactoryBot.build_stubbed(:simple_account, id: 1)
    event    = Invoices::InvoicesToReviewEvent.create(provider)

    assert event
    assert_equal event.provider, provider
  end
end
