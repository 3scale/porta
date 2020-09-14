# frozen_string_literal: true

require 'test_helper'

class InvoiceDecoratorTest < Draper::TestCase
  test '#buyer' do
    invoice = FactoryBot.build_stubbed(:invoice)

    assert_equal invoice.buyer.id, invoice.decorate.buyer.id
    assert_instance_of AccountDecorator, invoice.decorate.buyer
  end
end
