# frozen_string_literal: true

class Buyers::AccountPlansController < Api::PlansBaseController
  before_action :authorize_manage_account_plans!, :only => %i[new create]
  before_action :authorize_read_account_plans!

  activate_menu :serviceadmin, :submenu =>  :account_plans

  def index
    @new_plan = AccountPlan
  end

  def new
    @plan = collection.build params[:account_plan]
  end

  def edit; end

  # class super metod which is Api::PlansBaseController#create
  # to create plan same way as all plans
  #
  def create
    super params[:account_plan] do
      redirect_to admin_buyers_account_plans_path
    end
  end

  def update
    super params[:account_plan] do
      redirect_to admin_buyers_account_plans_path
    end
  end

  def destroy
    super do
      redirect_to admin_buyers_account_plans_path
    end
  end

  def masterize
    generic_masterize_plan(current_account, :default_account_plan)
  end

  protected

  def plans_index_path
    admin_buyers_account_plans_path
  end

  def collection
    current_account.account_plans
  end

  def authorize_manage_account_plans!
    authorize! :manage, :account_plans
  end

  def authorize_read_account_plans!
    authorize! :read, :account_plans
  end
end
