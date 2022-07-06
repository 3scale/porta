# frozen_string_literal: true

class Buyers::AccountPlansController < Api::PlansBaseController
  before_action :authorize_manage_account_plans!, only: %i[new create]
  before_action :authorize_read_account_plans!

  activate_menu! :audience, :accounts, :account_plans

  helper_method :default_plan_select_data, :plans_table_data, :no_available_plans
  delegate :default_plan_select_data, :plans_table_data, :no_available_plans, to: :presenter

  alias account_plans plans

  # rubocop:disable Lint/UselessMethodDefinition We need these, otherwise integration tests will fail
  def create
    super
  end

  def update
    super
  end

  def destroy
    super
  end
  # rubocop:enable Lint/UselessMethodDefinition

  def masterize
    super(current_account, :default_account_plan)
  end

  protected

  def plan_type
    :account_plan
  end

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

  def presenter
    @presenter ||= Buyers::AccountPlansPresenter.new(collection: collection, params: params)
  end
end
