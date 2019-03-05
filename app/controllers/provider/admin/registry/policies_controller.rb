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

  def update; end

  def edit
    policy = Policy.first
    @policy = Policies::PoliciesListService::PolicyList.new
    @policy.add policy
  end

  protected

  def create_policy_params
    params.permit(:name, :version, :schema)
  end
end
