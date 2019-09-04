require 'test_helper'

module Abilities
  class AccountsTest < ActiveSupport::TestCase
    def setup
      @provider = FactoryBot.create(:provider_account)
    end

    test "admin can't destroy himself" do
      user = @provider.admins.first
      assert_cannot Ability.new(user), :destroy, user
    end
  end
end