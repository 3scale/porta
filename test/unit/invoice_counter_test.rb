# frozen_string_literal: true

require 'test_helper'

class InvoiceCounterTest < ActiveSupport::TestCase
  setup do
    @invoice_count = FactoryGirl.create(:invoice_counter, invoice_count: 5)
  end

  test 'update_count' do
    assert_equal 5, @invoice_count.invoice_count

    @invoice_count.update_count(21)
    assert_equal 21, @invoice_count.invoice_count

    @invoice_count.reload
    assert_equal 21, @invoice_count.invoice_count
  end
end
