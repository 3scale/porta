require 'test_helper'

class Sites::ForumsControllerTest < ActionDispatch::IntegrationTest

  def setup
    provider = FactoryGirl.create(:provider_account)

    login_provider provider

    host! provider.admin_domain
  end

  def test_edit
    Account.any_instance.expects(:provider_can_use?).returns(true).at_least_once
    get edit_admin_site_forum_path
    assert_response :success

    Account.any_instance.expects(:provider_can_use?).returns(false).at_least_once
    get edit_admin_site_forum_path
    assert_response :forbidden
  end
end
