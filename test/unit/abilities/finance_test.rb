require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class Abilities::FinanceTest < ActiveSupport::TestCase
  def setup
    @provider = Factory(:provider_account)
  end

  test "provider can see finance section if hidden or visible" do
    admin = Factory(:user, :account => @provider, :role => :admin)
    ability = Ability.new(admin)

    @provider.settings.allow_finance!
    ability.reload!
    assert_can ability, :see, :finance
    assert_can ability, :admin, :finance

    @provider.settings.show_finance!
    ability.reload!
    assert_can ability, :see, :finance
    assert_can ability, :admin, :finance
  end

  test "if denied, provider can't see the finance section but can administrate it" do
    admin = Factory(:user, :account => @provider, :role => :admin)
    ability = Ability.new(admin)
    assert_cannot ability, :see, :finance
    assert_can ability, :admin, :finance
  end

end
