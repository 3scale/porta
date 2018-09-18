require 'test_helper'

class Provider::Admin::AccountsControllerTest < ActionController::TestCase

  def setup
    @account = Factory.create(:provider_account)
    host! @account.self_domain
    login_as(@account.admins.first)
    ThreeScale.config.redhat_customer_portal.stubs(enabled: false)
  end

  test '#update should redirect to edit credit card details' do
    Provider::Admin::AccountsController.any_instance.expects(:upgrading_account?).returns(true).twice
    Account.any_instance.stubs(:valid?).returns(true)
    put :update, account: {org_legaladdress: 'bla'}
    assert_redirected_to edit_provider_admin_account_braintree_blue_path(next_step: 'upgrade_plan')
  end

  test '#update should redirect to admin account' do
    Provider::Admin::AccountsController.any_instance.expects(:upgrading_account?).returns(false).twice
    Account.any_instance.stubs(:valid?).returns(true)
    put :update, account: {org_legaladdress: 'bla'}
    assert_redirected_to provider_admin_account_path
  end


  test '#update should require billing_information' do
    %w(org_legaladdress country state_region city zip vat_code).each do |field_name|
      FactoryGirl.create(:fields_definition, account: @account.provider_account, target: 'Account', name: field_name)
    end
    valid_params = {org_legaladdress: 'foo', country: 'Spain', state_region: 'qwe', city: 'asd', zip: 'zxc', vat_code: '1231234234'}

    Cinstance.any_instance.expects(:paid?).returns(false)
    put :update, account: {org_legaladdress: ''}
    assert assigns(:account).valid?

    Cinstance.any_instance.expects(:paid?).returns(false)
    put :update, account: {org_legaladdress: ''}, next_step: 'credit_card'
    refute assigns(:account).valid?
    assert assigns(:account).errors.messages[:org_legaladdress].present?

    Cinstance.any_instance.expects(:paid?).returns(false)
    put :update, account: valid_params, next_step: 'credit_card'
    assert assigns(:account).valid?, assigns(:account).errors.messages.to_s

    Cinstance.any_instance.expects(:paid?).returns(true)
    put :update, account: {org_legaladdress: ''}
    refute assigns(:account).valid?
    assert assigns(:account).errors.messages[:org_legaladdress].present?

    Cinstance.any_instance.expects(:paid?).returns(true)
    put :update, account: valid_params
    assert assigns(:account).valid?
  end
end
