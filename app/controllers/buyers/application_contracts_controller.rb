#FIXME: why is this controller not inheriting from Buyers::Base ?????
class Buyers::ApplicationContractsController < FrontendController
  include ApiAuthentication::ByProviderKeyAndBuyerUsername

  skip_before_action :login_required

  before_action :find_contract
  before_action :find_application_plan

  def change_plan
    respond_to do |wants|
      wants.xml do
        if @application_contract.change_plan!(@application_plan)
          render :xml => @application_contract.plan, :status => :ok
        else
          render :xml => @application_contract.errors, :status => :unprocessable_entity
        end
      end
    end
  end

  private

  def find_contract
    @application_contract = site_account.provided_cinstances.by_service(@service).find params[:id]
  end

  def find_application_plan
    @application_plan = site_account.application_plans.by_issuer(@service).published
      .find(params[:plan_id])
  end
end
