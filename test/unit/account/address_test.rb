require 'test_helper'

class Account::AddressTest < ActiveSupport::TestCase
  def setup
    @account = FactoryBot.create :simple_buyer, org_legaladdress: nil
  end

  test '#presence' do
    assert @account.address.blank?
    @account.update_attribute :org_legaladdress, "Street Foo"
    refute @account.reload.address.blank?
  end
end
