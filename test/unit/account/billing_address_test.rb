# frozen_string_literal: true

require 'test_helper'

class Account::BillingAddressTest < ActiveSupport::TestCase

  def setup
    @account = FactoryBot.create(:simple_provider,
                                  org_name: 'PP',
                                  org_legaladdress: "Palacio Moncloa",
                                  billing_address_name: 'Tim',
                                  billing_address_address1: 'C.Genova',
                                  billing_address_address2: 'num. 11')
  end

  test '#billing_address?' do
    account = Account.new

    assert account.billing_address
    refute account.billing_address?

    account.billing_address = { name: 'foo' }
    assert account.billing_address?
  end


  test 'address_for_invoice returns address if present' do
    assert_equal 'Palacio Moncloa', @account.address_for_invoice.line1
  end

  test 'address_for_invoice cascades to billing address' do
    @account.update_attribute :org_legaladdress, ""
    assert_equal 'C.Genova', @account.address_for_invoice.line1
  end

  test 'billing_address=' do
    account = Account.new
    error = assert_raises(Account::BillingAddress::AddressFormatError) do
      account.billing_address = 'Carrer Napols 187, Barcelona'
    end

    assert_equal account, error.object
  end

  test 'billing address has :address attribute which returns two address lines joined by \n' do
    assert_equal "C.Genova\nnum. 11", @account.billing_address[:address]
  end

  test ':address1 and :address2 are returned in the billing address hash' do
    assert_includes @account.billing_address.to_hash, :address1
    assert_includes @account.billing_address.to_hash, :address2
    assert_equal 'C.Genova', @account.billing_address[:address1]
    assert_equal 'num. 11', @account.billing_address[:address2]
  end

  test 'account org_name is used when billing_address_name is blank' do
    assert_equal 'Tim', @account.billing_address.name

    @account.update_attributes(billing_address_name: '')
    @account.reload

    assert_equal 'PP', @account.billing_address.name
  end
end
