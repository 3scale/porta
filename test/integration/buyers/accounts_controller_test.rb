require 'test_helper'

class Buyers::AccountsControllerTest < ActionDispatch::IntegrationTest

  def setup
    @provider = FactoryGirl.create(:provider_account)
    user = FactoryGirl.create(:active_user, account: @provider, role: :member, member_permission_ids: [:partners])
    login! @provider, user: user
  end

  def test_show
    buyer = FactoryGirl.create(:buyer_account, provider_account: @provider)
    service = FactoryGirl.create(:service, account: @provider)
    plan  = FactoryGirl.create(:application_plan, issuer: service)
    plan.publish!
    buyer.buy! plan
    cinstance = service.cinstances.last
    cinstance.update_attributes(name: 'Alaska Application App')

    User.any_instance.expects(:has_access_to_all_services?).returns(true).at_least_once
    get admin_buyers_account_path(buyer)
    assert_response :success
    assert_match 'Alaska Application App', response.body

    User.any_instance.expects(:has_access_to_all_services?).returns(false).at_least_once
    get admin_buyers_account_path(buyer)
    assert_response :success
    assert_not_match 'Alaska Application App', response.body

    User.any_instance.expects(:member_permission_service_ids).returns([service.id]).at_least_once
    get admin_buyers_account_path(buyer)
    assert_response :success
    assert_match 'Alaska Application App', response.body
  end
end
