require 'test_helper'

class DeveloperPortal::Admin::Messages::TrashControllerTest < DeveloperPortal::ActionController::TestCase

  def setup
    provider = FactoryGirl.create(:provider_account)
    @user    = FactoryGirl.create(:user, account: provider)

    host! provider.domain

    login_as @user
  end

  def test_index
    get :index

    assigned_drop_variables = assigns(:_assigned_drops).keys

    assert :success
    assert assigned_drop_variables.include?('messages')
    assert assigned_drop_variables.include?('pagination')
  end
end
