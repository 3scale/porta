#frozen_string_literal: true

class Provider::Admin::Registry::PoliciesController < Provider::Admin::BaseController
  activate_menu :account, :integrate, :policies

  layout 'provider'

  def index
    @policies = Policies::PoliciesListService.call(current_account, builtin: false)
  end

  def create
    policy = Policies::PolicyCreator.new(current_account, params).call
    @policy_list = Policies::PoliciesListService::PolicyList.new
    @policy_list.add policy

    if policy.persisted?
      redirect_to action: :edit, id: policy
    else
      render :new
    end
  end

  def update
    Policies::PolicyUpdater.new(policy, params).call
    @policy_list = Policies::PoliciesListService::PolicyList.new
    @policy_list.add policy

    if policy.persisted?
      redirect_to action: :index
    else
      render :edit
    end
  end

  def edit
    @policy_list = Policies::PoliciesListService::PolicyList.new
    @policy_list.add policy
  end

  protected

  def policy
    @policy ||= current_account.policies.find_by_id_or_name_version!(params[:id])
  end
end
