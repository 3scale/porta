require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class Finance::SettingsTest < ActionDispatch::IntegrationTest

  def setup
    @provider = Factory(:provider_account)
    @settings = @provider.settings
  end

  test 'billing strategy exists if and only if finance is allowed' do
    assert @settings.finance.denied?
    assert_nil @settings.account.billing_strategy

    @settings.allow_finance!
    assert_not_nil @settings.account.billing_strategy

    @settings.deny_finance!
    @settings.account.reload
    assert_nil @settings.account.billing_strategy
  end

end
