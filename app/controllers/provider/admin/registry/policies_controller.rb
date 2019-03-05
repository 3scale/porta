#frozen_string_literal: true

class Provider::Admin::Registry::PoliciesController < Provider::Admin::BaseController
  activate_menu :account, :integrate, :policies

  layout 'provider'

  def index
    @policies = Policies::PoliciesListService.call(current_account, builtin: false)
  end

  def create
    policy = current_account.create(create_policy_params)
    @policy = Policies::PoliciesListService.new
    @policy.add policy
  end

  def update
    policy = current_account.create(create_policy_params)
    @policy = Policies::PoliciesListService.new
    @policy.add policy
    if policy.update_attributes(create_policy_params)
      redirect_to :index
    else
      render :edit
    end
  end

  def edit
    policy = Policy.find_by_id_or_name_version!(params[:id])
    @policy = Policies::PoliciesListService::PolicyList.new
    @policy.add policy
  end

  protected

  def create_policy_params
    PermittedParams::PolicyParams.new(params.require(:policy)).to_params
  end
end
