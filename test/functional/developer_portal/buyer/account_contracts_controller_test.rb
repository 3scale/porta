require 'test_helper'

class DeveloperPortal::Buyer::AccountContractsControllerTest < DeveloperPortal::ActionController::TestCase

  def setup
    @provider = FactoryBot.create(:provider_account)
    @request.host = @provider.domain

    @buyer = FactoryBot.create(:buyer_account, :provider_account => @provider)
    login_as(@buyer.admins.first)
  end

  test "update fails" do
    @plan = @provider.account_plans.published.first
    @acc_plan = FactoryBot.create(:account_plan, :issuer => @provider)
    @acc_contract =  FactoryBot.create(:account_contract, :plan => @acc_plan, :user_account => @buyer)
    AccountContract.any_instance.stubs(:buyer_changes_plan!).returns(false)

    put :update, plan_id: @plan.id

    assert_response :redirect
    assert flash[:error].present?
  end
end
