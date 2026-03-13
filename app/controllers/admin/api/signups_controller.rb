# frozen_string_literal: true

class Admin::Api::SignupsController < Admin::Api::BaseController

  # Signup Express (Account Create)
  # POST /admin/api/signup.xml
  def create
    authorize!(:create, Account) if current_user

    @signup_result = account_manager.create(signup_params)

    check_creation_errors
    respond_with(@signup_result.account, user_options: { with_apps: true })
  end

  private

  def account_manager
    @account_manager ||= Signup::DeveloperAccountManager.new(current_account)
  end

  def user_params
    @user_params ||= begin
      allowed_attrs = account_manager.user.defined_fields_names + %w[password signup_type]
      flat_params.permit(*allowed_attrs).merge(signup_type: :minimal)
    end
  end

  def account_params
    @account_params ||= begin
      allowed_attrs = account_manager.account.defined_fields_names - %w[billing_address]
      flat_params.permit(*allowed_attrs)
    end
  end

  def check_creation_errors
    # FIXME: this really should not be needed
    # it should respond errors why buyer couldn't be created
    # and not respond with pathetic error
    raise ActiveRecord::RecordNotFound if @signup_result.errors[:plans].present?

    @signup_result.user.errors.each do |error|
      @signup_result.account.errors.add(error.attribute, error.message)
    end
  end

  def signup_params
    Signup::SignupParams.new(plans: plans, user_attributes: user_params, account_attributes: account_params, defaults: defaults)
  end

  def defaults
    { ApplicationPlan => { :name => 'API signup', :description => 'API signup', :create_origin => 'api' } }
  end

  def plans
    @plans ||= if plan_ids.present?
                 current_account.provided_plans.where(id: plan_ids)
               else
                 []
               end
  end

  def plan_ids
    %i[service account application].map {|type| params["#{type}_plan_id"] }.compact
  end

end
