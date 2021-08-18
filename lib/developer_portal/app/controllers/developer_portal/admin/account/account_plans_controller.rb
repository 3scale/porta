# TODO: this controller functionality is actually AccountContractController -
class DeveloperPortal::Admin::Account::AccountPlansController < ::DeveloperPortal::BaseController

    include ApiAuthentication::ByProviderKeyAndBuyerUsername

    before_action :authorize_account_plans

    before_action :find_plan, :except => :index
    activate_menu :account

    liquify prefix: 'account_plans', only: :index

    def index
      account_plans = Liquid::Drops::AccountPlan.wrap(site_account.account_plans.published)
      assign_drops account_plans: account_plans
    end

    def change
      cinstance = current_account.bought_cinstance
      cinstance.change_plan!(@plan)

      respond_to do |format|
        format.html do
          redirect_to :action => :index
        end

        format.any(:xml, :json) { head :ok }
      end
    end

  private

    def authorize_account_plans
      authorize! :see, :account_plans
    end

    def find_plan
      @plan = site_account.application_plans.published.find(params[:id])
    end

  end
