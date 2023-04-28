# frozen_string_literal: true

class Admin::Api::SignupsController < Admin::Api::BaseController

  # Signup Express (Account Create)
  # POST /admin/api/signup.xml
  def create
    authorize!(:create, Account) if current_user

    @signup_result = Signup::DeveloperAccountManager.new(current_account).create(signup_params)

    check_creation_errors
    respond_with(@signup_result.account, with_apps: true)
  end

  private

  def user_params
    flat_params.merge({signup_type: :minimal})
  end

  def check_creation_errors
    # FIXME: this really should not be needed
    # it should respond errors why buyer couldn't be created
    # and not respond with pathetic error
    raise ActiveRecord::RecordNotFound if @signup_result.errors[:plans].present?

    @signup_result.user.errors.each do |attr, error|
      @signup_result.account.errors.add(attr, error)
    end
  end

  def signup_params
    Signup::SignupParams.new(plans: plans, user_attributes: user_params, account_attributes: flat_params, defaults: defaults)
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
