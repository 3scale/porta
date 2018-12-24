require 'test_helper'

class LogEntryTest < ActiveSupport::TestCase
  def setup
    @provider = FactoryBot.create(:provider_account)
    @buyer = FactoryBot.create(:buyer_account, :provider_account => @provider)
  end

  test 'create all log levels' do
    LogEntry.log :info, 'all your base are belong to us', @provider, @buyer
    LogEntry.log :warning, 'all your base are belong to us', @provider, @buyer
    LogEntry.log :error, 'all your base are belong to us', @provider, nil
    assert_equal 3, @provider.log_entries.size
  end

  test 'refers to associations if supplied' do
    entry = LogEntry.log :info, 'all your base are belong to us', @provider, @buyer
    assert_not_nil entry.provider
    assert_not_nil entry.buyer
  end

  test 'filters by buyer shows buyer and globals' do
    @buyer2 = FactoryBot.create(:buyer_account, :provider_account => @provider)
    Account.stubs(:search_ids).returns([@buyer.id])

    LogEntry.log :info, 'all your base are belong to us', @provider, @buyer
    LogEntry.log :warning, 'all your base are belong to us', @provider, @buyer2
    LogEntry.log :error, 'all your base are belong to us', @provider, nil

    assert_equal 2, @provider.log_entries.by_buyer_query(@buyer).size
  end


  def test_truncate_description
    LogEntry.log(:info, "a" * 300, @provider, @buyer)
    log_entry = LogEntry.last!
    assert_equal 255, log_entry.description.length
  end

end
