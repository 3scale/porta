require 'test_helper'

class Provider::Admin::AccountsTest < ActionDispatch::IntegrationTest

  DoubleField = Struct.new(:name)

  def setup
    @provider = FactoryBot.create(:provider_account)
    @master = @provider.provider_account

    login_provider @provider

    host! @provider.admin_domain
  end

  def test_update
    FactoryBot.create(:fields_definition, account: @master, target: 'Account', name: 'org_legaladdress')

    Account.any_instance.expects(:editable_defined_fields_for).returns([DoubleField.new('org_legaladdress')]).once
    put provider_admin_account_path(account: { extra_fields: { org_legaladdress: 'alaska' }})
    assert_equal 'alaska', @provider.reload.org_legaladdress

    Account.any_instance.expects(:editable_defined_fields_for).returns([DoubleField.new('org_legaladdress')]).once
    put provider_admin_account_path(account: { org_legaladdress: 'estonia' })
    assert_equal 'estonia', @provider.reload.org_legaladdress

    Account.any_instance.expects(:editable_defined_fields_for).returns([]).once
    put provider_admin_account_path(account: { extra_fields: { org_legaladdress: 'wild' }})
    assert_equal 'estonia', @provider.reload.org_legaladdress
  end

  def test_update_not_fail
    # extra_fields are blank
    put provider_admin_account_path(account: { timezone: 'CEST' })
    assert_response :success
  end
end
