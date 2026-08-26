# frozen_string_literal: true

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

  include Stale

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

  def api_controller?
    true
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

  def account_params
    defined_fields_names = current_account.defined_fields_names_for(Account)
    allowed_attrs = defined_fields_names + %w[name]
    nested_params = {
      extra_fields: current_account.defined_extra_fields_names_for(Account),
      annotations: {}
    }

    if defined_fields_names.include?('billing_address')
      allowed_attrs += %w[billing_address_name billing_address_address1 billing_address_address2 billing_address_city
                          billing_address_country billing_address_state billing_address_zip billing_address_phone]
      nested_params[:billing_address] = %w[name address1 address2 city country state zip phone]
    end

    params.permit(*allowed_attrs, **nested_params)
  end
end
