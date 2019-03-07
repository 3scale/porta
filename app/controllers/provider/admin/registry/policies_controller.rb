#frozen_string_literal: true

class Provider::Admin::Registry::PoliciesController < Provider::Admin::BaseController
  activate_menu :account, :integrate, :policies
  before_action :authorize_policies

  before_action :policy, only: [:edit, :update]

  layout 'provider'

  def new
    @policy = current_account.policies.build
  end

  def index
    @policies = current_account.policies
  end

  def create
    @policy = Policies::PolicyCreator.new(current_account, params).call
    @policy_list = Policies::PoliciesListService::PolicyList.new
    @policy_list.add @policy

    if @policy.persisted?
      redirect_to action: :edit, id: policy
    else
      render :new
    end
  end

  def update
    if policy.errors.empty?
      redirect_to action: :index
    else
      render :edit
    end
  end

  protected

  def authorize_policies
    authorize! :manage, :policy_registry
  end

  def policy
    @policy ||= current_account.policies.find_by_id_or_name_version!(params[:id])
  end
end
