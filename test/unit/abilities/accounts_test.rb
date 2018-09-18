require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class Abilities::AccountsTest < ActiveSupport::TestCase
  def setup
    @provider = Factory(:provider_account)
  end

  test "admin can't destroy himself" do
    user = @provider.admins.first
    assert_cannot Ability.new(user), :destroy, user
  end
end
