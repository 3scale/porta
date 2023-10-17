require 'test_helper'

class ProviderTest < ActiveSupport::TestCase
  def test_find
    provider = FactoryBot.create(:simple_provider)

    assert_equal provider, Provider.find(provider.id)
  end

  def test_find_with_master
    assert_equal master_account, Provider.find(master_account.id)
  end

  test 'should never return self as a buyer account' do
    assert_equal master_account, master_account.provider_account

    assert_not_includes master_account.buyer_accounts, master_account
  end

  test 'publishes domain events when changed' do
    provider = FactoryBot.create(:simple_provider)

    Domains::ProviderDomainsChangedEvent.expects(:create).with(provider)

    provider.domain = 'example.com'

    assert provider.save!
  end

  test 'publishes domain events when removed' do
    provider = FactoryBot.create(:simple_provider)

    Domains::ProviderDomainsChangedEvent.expects(:create).with(provider)

    provider.destroy
  end
end
