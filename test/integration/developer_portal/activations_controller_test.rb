require 'test_helper'

class DeveloperPortal::ActivationsControllerTest < ActionDispatch::IntegrationTest

  def setup
    @buyer    = FactoryBot.create(:buyer_account)
    @provider = @buyer.provider_account
    @user     = FactoryBot.create(:pending_user, account: @buyer)
    @service  = @provider.first_service!

    host! @provider.domain
  end

  test 'wrong activation code' do
    get developer_portal.activate_path activation_code: 'code123'

    assert_response :success
  end

  test 'successfully activate user' do
    get developer_portal.activate_path activation_code: @user.activation_code

    assert_response :redirect

    @user.reload

    assert_equal true, @user.active?
  end

  test 'account required approval flash message' do
    Account.any_instance.expects(:approval_required?).returns(true)

    get developer_portal.activate_path activation_code: @user.activation_code

    assert_equal flash[:notice], I18n.t('errors.messages.activation_approval_required')
  end

  test 'activation complete flash message' do
    Account.any_instance.expects(:approval_required?).returns(false)

    get developer_portal.activate_path activation_code: @user.activation_code

    assert_equal flash[:notice], I18n.t('errors.messages.activation_complete')
  end

  test 'emails has been taken problem' do
    second_user = Factory.build(:pending_user, account: @buyer, email: @user.email)

    second_user.save validate: false

    get developer_portal.activate_path activation_code: @user.activation_code

    assert_response :redirect

    assert_equal flash[:error], I18n.t('errors.messages.duplicated_user_buyer_side')
  end

  test 'does not try anything on HEAD request' do
    @user.activate!
    @user.update_column :activation_code, 'new-code-for-testing'
    head developer_portal.activate_path activation_code: @user.activation_code
    assert_response :success
    assert response.body.blank?
  end
end
