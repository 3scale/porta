# frozen_string_literal: true

require 'test_helper'

class AdminSectionTest < ActiveSupport::TestCase
  def test_permissions
    refute AdminSection.permissions.include?(:services)
    assert AdminSection.permissions.include?(:plans)
  end

  def test_permissions_with_finance
    ThreeScale.stubs(master_on_premises?: true)
    refute AdminSection.permissions.include?(:finance)

    ThreeScale.stubs(master_on_premises?: false)
    assert AdminSection.permissions.include?(:finance)
  end

  def test_permissions_for_account
    account = FactoryBot.create(:simple_provider)

    account.stubs(provider_can_use?: true)
    assert_same_elements AdminSection.permissions, AdminSection.permissions_for_account(account)

    account.stubs(provider_can_use?: false)
    assert_same_elements (AdminSection.permissions.reject { |permission| permission == :policy_registry }), AdminSection.permissions_for_account(account)
  end
end
