# frozen_string_literal: true

require 'test_helper'

class Abilities::ProviderAdminTest < ActiveSupport::TestCase
  setup do
    @account = Account.new
    @account.stubs(provider?: true)
    @account.stubs(:provider_can_use?).with(any_parameters).returns(false)
    @user = User.new({account: @account}, without_protection: true)
  end

  def test_policies_allowed
    @account.expects(:provider_can_use?).with(:policy_registry).returns(true)
    @account.stubs(tenant?: true)

    assert_can Ability.new(@user), :manage, :policy_registry
  end

  def test_policies_no_rolling_update
    @account.expects(:provider_can_use?).with(:policy_registry).returns(false)
    @account.stubs(tenant?: true)

    assert_cannot Ability.new(@user), :manage, :policy_registry
  end

  def test_policies_not_tenant
    @account.stubs(tenant?: false)

    assert_cannot Ability.new(@user), :manage, :policy_registry
  end
end
