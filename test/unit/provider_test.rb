require 'test_helper'

class ProviderTest < ActiveSupport::TestCase
  def setup
    master_account
  end

  def test_find
    provider = Account.create!(org_name: 'Mr. Provider') {|p| p.provider = true }

    assert_equal provider, Provider.find(provider.id)
  end

  def test_find_with_master
    assert_equal master_account, Provider.find(master_account.id)
  end
end
