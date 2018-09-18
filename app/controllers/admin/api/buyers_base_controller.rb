class Admin::Api::BuyersBaseController < Admin::Api::BaseController

  protected

  def buyer
    @buyer ||= current_account.buyers.find(params[:account_id])
  end

  def accessible_bought_cinstances
    buyer.bought_cinstances.where(service: accessible_services)
  end
end
