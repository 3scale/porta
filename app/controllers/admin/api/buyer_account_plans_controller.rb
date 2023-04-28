class Admin::Api::BuyerAccountPlansController < Admin::Api::BuyersBaseController
  #TODO: security tests are needed!!!!

  # Account Fetch Account Plan
  # GET /admin/api/accounts/{account_id}/plan.xml
  def show
    respond_with(bought_account_plan)
  end

  private

  def bought_account_plan
    @bought_account_plan ||= buyer.bought_account_plan
  end

end
