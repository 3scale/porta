class Admin::Api::BaseController < ApplicationController
  around_action :notification_center

  before_action :force_provider_or_master_domain
  after_action :report_traffic

  skip_after_action :update_current_user_after_login

  include SiteAccountSupport

  include ApiAuthentication::SuspendedAccount
  include ApiAuthentication::ByAccessToken
  include ApiAuthentication::ByProviderKey
  include ApiSupport::PrepareResponseRepresenter
  include ApiSupport::Params

  include ::Admin::Api::Filters::Pagination
  include ::ThreeScale::Warnings::ControllerExtension
  include Logic::RollingUpdates::Controller

  extend ::Filters::ProviderRequired
  provider_required

  self.access_token_scopes = :account_management

  rescue_from ActiveRecord::RecordNotUnique do
    head(:conflict)
  end

  rescue_from StateMachines::InvalidTransition do |error|
    handle_state_machine_invalid_transition(error)
  end

  rescue_from ::Account::BillingAddress::AddressFormatError, with: :handle_billing_address_error

  protected

  def notification_center
    silent_about(ApplicationKey) do
      yield
    end
  end

  def metric_to_report
    :account
  end

  def required_params(*args)
    args.flatten.detect {|key| params[key].blank? }
  end

  def authorize_switch!(name)
    current_account.settings.switches[name].allowed? or raise CanCan::AccessDenied
  end

  def search
    ThreeScale::Search.new(params)
  end

  def handle_state_machine_invalid_transition(error)
    respond_with error,
                 responder: ThreeScale::Api::ErrorResponder,
                 represent_with: StateMachine::InvalidTransitionRepresenter
  end

  def handle_billing_address_error(error)
    respond_with error,
                 responder: ThreeScale::Api::ErrorResponder,
                 represent_with: AccountBillingAddressErrorRepresenter
  end

  private

  def accessible_services
    (current_user || current_account).accessible_services
  end

  def accessible_application_plans
    current_account.application_plans.where(issuer: accessible_services)
  end

  def authorize_account_plans!
    authorize!(:admin, :account_plans) if current_user
  end

  def authorize_service_plans!
    authorize!(:admin, :service_plans) if current_user
  end

  ## Defining common parameters

  ##~ @parameter_access_token = { :name => "access_token", :description => "A personal Access Token", :dataType => "string", :required => true, :paramType => "query", :threescale_name => "access_token"}
  ##~ @parameter_system_name_by_name = {:name => "system_name", :description => "System Name of the object to be created. System names cannot be modified after creation, they are used as the key to identify the objects.", :dataType => "string", :paramType => "query"}
  ##~ @parameter_page = {:name => "page", :description => "Page in the paginated list. Defaults to 1.", :dataType => "int", :paramType => "query", :defaultValue => "1"}
  ##~ @parameter_per_page = {:name => "per_page", :description => "Number of results per page. Default and max is 500.", :dataType => "int", :paramType => "query", :defaultValue => "500"}

  ## Plans

  ##~ @parameter_application_plan_id_by_name = {:name => "application_plan_id", :description => "ID of the application plan (if not assigned default will be used instead).", :dataType => "int", :required => false, :paramType => "query", :threescale_name => "application_plan_ids"}
  ##~ @parameter_application_plan_id_by_id_name = {:name => "application_plan_id", :description => "ID of the application plan.", :dataType => "int", :required => true, :paramType => "path", :threescale_name => "application_plan_ids"}
  ##~ @parameter_application_plan_id_by_id = {:name => "id", :description => "ID of the application plan.", :dataType => "int", :required => true, :paramType => "path", :threescale_name => "application_plan_ids"}

  ##~ @parameter_account_plan_id_by_name = {:name => "account_plan_id", :description => "ID of the account plan (if not assigned default will be used instead).", :dataType => "int", :required => false, :paramType => "query", :threescale_name => "account_plan_ids"}
  ##~ @parameter_account_plan_id_by_id_name = { :name => "account_plan_id", :description => "ID of the account plan.", :dataType => "int", :required => true, :paramType => "path", :threescale_name => "account_plan_ids"}
  ##~ @parameter_account_plan_id_by_id = { :name => "id", :description => "ID of the account plan.", :dataType => "int", :required => true, :paramType => "path", :threescale_name => "account_plan_ids"}

  ##~ @parameter_service_plan_id_by_name = {:name => "service_plan_id", :description => "ID of the service plan (if not assigned default will be used instead).", :dataType => "int", :required => false, :paramType => "query", :threescale_name => "service_plan_ids"}
  ##~ @parameter_service_plan_id_by_id = {:name => "id", :description => "ID of the service plan.", :dataType => "int", :required => true, :paramType => "path" , :threescale_name => "service_plan_ids"}
  ##~ @parameter_service_plan_id_by_id_name = {:name => "service_plan_id", :description => "ID of the service plan.", :dataType => "int", :required => true, :paramType => "path" , :threescale_name => "service_plan_ids"}
  #
  ##~ @parameter_end_user_plan_id_by_name = {:name => "end_user_plan_id", :description => "ID of the end user plan (if not assigned default will be used instead).", :dataType => "int", :required => false, :paramType => "query", :threescale_name => "end_user_plan_ids"}
  ##~ @parameter_end_user_plan_id_by_id_name = {:name => "end_user_plan_id", :description => "ID of the end user plan.", :dataType => "int", :required => true, :paramType => "path", :threescale_name => "end_user_plan_ids"}
  ##~ @parameter_end_user_plan_id_by_id = {:name => "id", :description => "ID of the end user plan.", :dataType => "int", :required => true, :paramType => "path", :threescale_name => "end_user_plan_ids"}


  ## Users

  ##~ @parameter_admin_id_by_id = { :name => "id", :description => "ID of the user.", :dataType => "int", :allowMultiple => false, :required => true, :paramType => "path" }
  ##~ @parameter_admin_id_by_id["threescale_name"] = "admin_ids"

  ##~ @parameter_user_state = {:name => "state", :description => "Filter users by State." , :dataType => "string", :paramType => "query", :required => false, :defaultValue => "", :allowableValues => {:values => ["pending","suspended","active"], :valueType => "LIST"}}
  ##~ @parameter_user_role = {:name => "role", :description => "Filter users by Role." , :dataType => "string",  :paramType => "query", :required => false, :defaultValue => "", :allowableValues => {:values => ["member","admin"], :valueType => "LIST"}}

  ##~ @parameter_user_id_by_id   = {:name => "id", :description => "ID of the user.", :dataType => "int", :required => true, :paramType => "path", :threescale_name => "user_ids"}
  ##~ @parameter_user_id_by_id_name   = {:name => "user_id", :description => "ID of the user.", :dataType => "int", :required => true, :paramType => "path", :threescale_name => "user_ids"}

  ## Services

  ##~ @parameter_service_id_by_id = {:name => "id", :description => "ID of the service.", :dataType => "int", :required => true, :paramType => "path", :threescale_name => "service_ids"}
  ##~ @parameter_service_id_by_id_name = {:name => "service_id", :description => "ID of the service.", :dataType => "int", :required => true, :paramType => "path", :threescale_name => "service_ids"}

  ## Features

  ##~ @parameter_feature_id_by_id = {:name => "id", :description => "ID of the feature.", :dataType => "int", :required => true, :paramType => "path" }
  ##~ @parameter_feature_id_by_name = {:name => "feature_id", :description => "ID of the feature.", :dataType => "int", :required => true, :paramType => "query" }

  ## Metrics

  ##~ @parameter_metric_id_by_id = {:name => "id", :description => "ID of the metric.", :dataType => "int", :required => true, :paramType => "path", :threescale_name => "metric_ids" }
  ##~ @parameter_metric_id_by_id_name = {:name => "metric_id", :description => "ID of the metric.", :dataType => "int", :required => true, :paramType => "path", :threescale_name => "metric_ids"}

  ## Methods

  ##~ @parameter_method_id_by_id = {:name => "id", :description => "ID of the method.", :dataType => "int", :required => true, :paramType => "path" }

  ## Limits

  ##~ @parameter_limit_id_by_id   = {:name => "id", :description => "ID of the limit.", :dataType => "int", :required => true, :paramType => "path" }
  ##~ @parameter_limit_period = {:name => "period", :description => "Period of the limit.", :dataType => "string", :required => true, :paramType => "query", :defaultValue => "minute", :allowableValues => {:values => ["eternity","year","month","week","day","hour","minute"], :valueType => "LIST"}}

  ## Accounts

  ##~ @parameter_account_id_by_id = {:name => "id", :description => "ID of the account.", :dataType => "int", :required => true, :paramType => "path", :threescale_name => "account_ids"}
  ##~ @parameter_account_id_by_id_name = {:name => "account_id", :description => "ID of the account.", :dataType => "int", :required => true, :paramType => "path", :threescale_name => "account_ids"}
  ##~ @parameter_account_state = {:name => "state", :description => "Account state.", :dataType => "string", :paramType => "query", :required => false, :defaultValue => "", :allowableValues => {:values => ["pending","approved","rejected"], :valueType => "LIST"}}

  ## Applications

  ##~ @parameter_application_id_by_id = {:name => "id", :description => "ID of the application.", :dataType => "int", :required => true, :paramType => "path", :threescale_name => "application_ids"}
  ##~ @parameter_application_id_by_id_name = {:name => "application_id", :description => "ID of the application.", :dataType => "int", :required => true, :paramType => "path", :threescale_name => "application_ids"}
  ##~ @parameter_application_id_by_name = {:name => "application_id", :description => "ID of the application.", :dataType => "int", :required => false, :paramType => "query", :threescale_name => "application_ids"}

  ## End Users

  ##~ @parameter_end_user_username_by_id = {:name => "username", :description => "Username (unique identifier) of the end user.", :dataType => "string", :required => true, :paramType => "path"}
  ##~ @parameter_end_user_username_by_name = {:name => "username", :description => "Username (unique identifier) of the end user.", :dataType => "string", :required => true, :paramType => "query"}

  ## ActiveDocs

  ##~ @parameter_active_doc_id_by_id = {:name => "id", :description => "ID of the ActiveDocs spec", :dataType => "int", :required => true, :paramType => "path"}

  ## Extra

  ##~ @parameter_extra = {:name => "additional_fields", :dataType => "custom", :paramType => "query", :allowMultiple => true, :description => "Additional fields have to be defined by name and value (i.e &name=value). You can add as many as you want. Additional fields are the custom fields declared in 'Settings >> Fields Definitions' on your API Admin Portal. Typical examples are 'url', 'country', etc. Please check your Fields Definitions to get the list of all your custom fields."}
  ##~ @parameter_extra_provider = {:name => "additional_fields", :dataType => "custom", :paramType => "query", :allowMultiple => true, :description => "Additional fields have to be defined by name and value (i.e &name=value). Additional fields are the custom fields declared for your tenant, you can find them in 'Settings >> Personal Details' for the account and in 'Settings >> Account >> Users >> Personal Details' for users. Typical examples are 'url', 'country', etc. Please check your Fields Definitions to get the list of all your custom fields."}
  ##~ @parameter_extra_short = {:name => " ", :dataType => "custom", :paramType => "query", :allowMultiple => true, :description => "Extra parameters"}

  ## ProxyConfigs

  ##~ @parameter_environment = { :name => "environment", :description => "Gateway environment. Must be 'sandbox' or 'production'", :dataType => "string", :required => true, :paramType => "path", :threescale_name => "environment"}
  ##~ @parameter_proxy_config_version_by_version = { :name => "version", :description => "Version of the Proxy config.", :dataType => "int", :required => true, :paramType => "path", :threescale_name => "proxy_config_version"}
end
