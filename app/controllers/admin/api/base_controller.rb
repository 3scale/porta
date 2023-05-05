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
end
