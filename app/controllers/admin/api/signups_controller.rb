# frozen_string_literal: true

class Admin::Api::SignupsController < Admin::Api::BaseController

  # swagger
  ##~ sapi = source2swagger.namespace("Account Management API")
  #
  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/signup.xml"
  ##~ e.responseClass = "account"

  ##~ op = e.operations.add
  ##~ op.httpMethod = "POST"
  ##~ op.summary = "Signup Express (Account Create)"
  ##~ op.description = "This request allows you to reproduce a developer sign-up in a single API call. It will create an Account, an Admin User for the account, and optionally an Application with its keys. If the plan_id is not passed, the default plan will be used instead. You can add additional custom parameters in Fields Definition on your Admin Portal."
  ##~ op.group = "signup"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add :name => "org_name", :description => "Organization Name of the developer account.", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.parameters.add :name => "username", :description => "Username of the admin user (on the new developer account).", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.parameters.add :name => "email", :description => "Email of the admin user.", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.parameters.add :name => "password", :description => "Password of the admin user.", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.parameters.add @parameter_account_plan_id_by_name
  ##~ op.parameters.add @parameter_service_plan_id_by_name
  ##~ op.parameters.add @parameter_application_plan_id_by_name
  ##~ op.parameters.add @parameter_extra

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
