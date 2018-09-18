class NotificationMailer < ActionMailer::Base
  default from: Rails.configuration.three_scale.notification_email

  layout 'notification_email'

  helper CinstancesHelper
  include CinstancesHelper

  class_attribute :event_mapping, :hidden_notifications, :required_abilities, :hidden_onprem_multitenancy

  attr_reader :provider_account, :receiver, :event

  after_action :event_to_header

  self.event_mapping = Hash.new { |h, k| h[k] = [] }
  self.hidden_notifications = []
  self.required_abilities   = {}
  self.hidden_onprem_multitenancy = []

  def self.available_notifications
    event_mapping.keys.freeze
  end

  class << self

    attr_accessor :event_class, :hidden, :abilities, :hidden_om

    def method_added(name)
      return if event_class.blank?

      event_mapping[name] = event_class
      hidden_notifications << name if hidden
      required_abilities[name] = abilities.to_a if abilities.present?
      hidden_onprem_multitenancy << name if hidden_om

      self.event_class = nil
      self.hidden      = false
      self.abilities   = {}
      self.hidden_om   = false
    end

    def delivers(event_class, hidden: false, abilities: {}, hidden_onprem_multitenancy: false)
      self.event_class = event_class
      self.hidden      = hidden
      self.abilities   = abilities
      self.hidden_om   = hidden_onprem_multitenancy
    end
  end

  # The order of the methods below directly defines the order in which they
  # are displayed on the notification preferences page.

  # @param [Applications::ApplicationCreatedEvent] event
  # @param [User] receiver
  delivers Applications::ApplicationCreatedEvent
  def application_created(event, receiver)
    @application      = event.application
    @provider_account = event.provider
    @service          = event.service
    @account          = event.account
    @user             = event.user
    @receiver         = receiver
    @event            = event

    mail to: @receiver.email,
         subject: "#{@application.name} created on #{@service.name}"
  end

  # @param [Accounts::AccountCreatedEvent] event
  # @param [User] receiver
  delivers Accounts::AccountCreatedEvent, hidden_onprem_multitenancy: true
  def account_created(event, receiver)
    @provider_account = event.provider
    @account          = event.account
    @receiver         = receiver
    @user             = event.user
    @event            = event

    mail to: @receiver.email,
         subject: "#{@user.informal_name} from #{@account.name} signed up"
  end

  # @param [Alerts::LimitAlertReachedProviderEvent] event
  # @param [User] receiver
  delivers Alerts::LimitAlertReachedProviderEvent
  def limit_alert_reached_provider(event, receiver)
    limit_mail(event, receiver, :limit_alert_reached_provider)
  end

  # @param [Alerts::LimitViolationReachedProviderEvent] event
  # @param [User] receiver
  delivers Alerts::LimitViolationReachedProviderEvent
  def limit_violation_reached_provider(event, receiver)
    limit_mail(event, receiver, :limit_violation_reached_provider)
  end

  # @param [Accounts::AccountPlanChangeRequestedEvent] event
  # @param [User] receiver
  delivers Accounts::AccountPlanChangeRequestedEvent, hidden_onprem_multitenancy: true
  def account_plan_change_requested(event, receiver)
    @provider_account = event.provider
    @receiver         = receiver
    @user             = event.user
    @account          = @user.account
    @current_plan     = event.current_plan
    @requested_plan   = event.requested_plan
    @event            = event

    mail to: @receiver.email, subject: "#{@account.name} has requested a plan change"
  end

  # @param [Accounts::AccountDeletedEvent] event
  # @param [User] receiver
  delivers Accounts::AccountDeletedEvent
  def account_deleted(event, receiver)
    @provider_account = event.provider
    @account_name     = event.account_name
    @receiver         = receiver
    @event            = event

    mail to: @receiver.email, subject: "Account #{@account_name} deleted"
  end

  # @param [Cinstances::CinstanceCancellationEvent] event
  # @param [User] receiver
  delivers Cinstances::CinstanceCancellationEvent, hidden_onprem_multitenancy: true
  def cinstance_cancellation(event, receiver)
    @provider_account = event.provider
    @receiver         = receiver
    @cinstance_name   = event.cinstance_name
    @plan_name        = event.plan_name
    @service_name     = event.service_name
    @account_name     = event.account_name
    @event            = event

    # TODO
    # return if attributes does not exist?

    mail to: @receiver.email, subject: "Application #{@cinstance_name} has been deleted"
  end

  # @param [Cinstances::CinstancePlanChangedEvent] event
  # @param [User] receiver
  delivers Cinstances::CinstancePlanChangedEvent, hidden_onprem_multitenancy: true
  def cinstance_plan_changed(event, receiver)
    @provider_account = event.provider
    @receiver         = receiver
    @user             = event.user
    @account          = event.account
    @cinstance        = event.cinstance
    @service          = @cinstance.service
    @new_plan         = event.new_plan
    @old_plan         = event.old_plan
    @event            = event

    mail to: @receiver.email, subject: "Application #{@cinstance.name} has changed to plan #{@new_plan.name}"
  end

  delivers Applications::ApplicationPlanChangeRequestedEvent, hidden_onprem_multitenancy: true
  def application_plan_change_requested(event, receiver)
    @provider_account = event.provider
    @receiver         = receiver
    @account          = event.account
    @current_plan     = event.current_plan
    @requested_plan   = event.requested_plan
    @application      = event.application
    @service          = @application.service
    @user             = event.user
    @event            = event

    mail to: @receiver.email, subject: "Action required: #{@user.username} from #{@account.org_name} requested an app plan change"
  end

  # @param [ServiceContracts::ServiceContractCreatedEvent] event
  # @param [User] receiver
  delivers ServiceContracts::ServiceContractCreatedEvent
  def service_contract_created(event, receiver)
    @provider_account = event.provider
    @receiver         = receiver
    @service          = event.service
    @user             = event.user
    @plan             = event.plan
    @account          = Liquid::Drops::Account.new(event.account)
    @event            = event

    mail to: @receiver.email,
         subject: "#{@account.name} has subscribed to your service #{@service.name}"
  end

  delivers Services::ServicePlanChangeRequestedEvent, hidden_onprem_multitenancy: true
  def service_plan_change_requested(event, receiver)
    @provider_account = event.provider
    @user             = event.user
    @receiver         = receiver
    @account          = event.account
    @current_plan     = event.current_plan
    @requested_plan   = event.requested_plan
    @service          = event.service
    @event            = event

    mail to: @receiver.email, subject: "Action needed: service subscription change request by #{@account.name}."
  end

  # @param [ServiceContracts::ServiceContractPlanChangedEvent] event
  # @param [User] receiver
  delivers ServiceContracts::ServiceContractPlanChangedEvent, hidden_onprem_multitenancy: true
  def service_contract_plan_changed(event, receiver)
    @provider_account = event.provider
    @receiver         = receiver
    @service_contract = event.service_contract
    @service          = @service_contract.service
    @user             = event.user
    @account          = event.account
    @new_plan         = event.new_plan
    @old_plan         = event.old_plan
    @event            = event

    mail to: @receiver.email, subject: "#{@account.name} has changed subscription to #{@new_plan.name}"
  end

  # @param [ServiceContracts::ServiceContractCancellationEvent] event
  # @param [User] receiver
  delivers ServiceContracts::ServiceContractCancellationEvent
  def service_contract_cancellation(event, receiver)
    @provider_account = event.provider
    @receiver         = receiver
    @account_name     = event.account_name
    @plan_name        = event.plan_name
    @service_name     = event.service_name
    @event            = event

    mail to: @receiver.email, subject: "#{@account_name} has cancelled their subscription"
  end

  # @param [Cinstances::CinstanceExpiredTrialEvent] event
  # @param [User] receiver
  delivers Cinstances::CinstanceExpiredTrialEvent, hidden_onprem_multitenancy: true
  def cinstance_expired_trial(event, receiver)
    @service          = event.service
    @plan             = event.plan
    @provider_account = event.provider
    @receiver         = receiver
    @account          = event.account
    @event            = event
    @application      = event.cinstance

    mail to: @receiver.email, subject: "#{@account.name}'s trial of the #{application_friendly_name(@application)} on the #{@plan.name} has expired"
  end

  # @param [Invoices::InvoicesToReviewEvent] event
  # @param [User] receiver
  delivers Invoices::InvoicesToReviewEvent
  def invoices_to_review(event, receiver)
    @provider_account = event.provider
    @receiver         = receiver
    @event            = event

    mail to: @receiver.email, subject: 'Action needed: review invoices'
  end

  # @param [Plans::PlanDowngradedEvent] event
  # @param [User] receiver
  delivers Plans::PlanDowngradedEvent, hidden_onprem_multitenancy: true
  def plan_downgraded(event, receiver)
    @provider_account = event.provider
    @receiver         = receiver
    @account          = event.account
    @old_plan         = event.old_plan
    @new_plan         = event.new_plan
    @event            = event

    mail to: @receiver.email, subject: "#{@account.name} has downgraded"
  end

  # @param [Accounts::ExpiredCreditCardProviderEvent] event
  # @param [User] receiver
  delivers Accounts::ExpiredCreditCardProviderEvent
  def expired_credit_card_provider(event, receiver)
    @provider_account = event.provider
    @receiver         = receiver
    @account          = event.account
    @event            = event

    mail to: @receiver.email, subject: "#{@account.name}’s credit card is due to expire"
  end

  # @param [Invoices::UnsuccessfullyChargedInvoiceProviderEvent] event
  # @param [User] receiver
  delivers Invoices::UnsuccessfullyChargedInvoiceProviderEvent
  def unsuccessfully_charged_invoice_provider(event, receiver)
    @provider_account = event.provider
    @account          = event.invoice.buyer_account
    @receiver         = receiver
    @event            = event

    mail to: @receiver.email, subject: "#{@account.name}'s payment has failed"
  end

  # @param [Invoices::UnsuccessfullyChargedInvoiceFinalProviderEvent] event
  # @param [User] receiver
  delivers Invoices::UnsuccessfullyChargedInvoiceFinalProviderEvent
  def unsuccessfully_charged_invoice_final_provider(event, receiver)
    @provider_account = event.provider
    @account          = event.invoice.buyer_account
    @receiver         = receiver
    @event            = event

    mail to: @receiver.email, subject: "#{@account.name}'s payment has failed without retry"
  end

  # @param [Messages::MessageReceivedEvent] event
  # @param [User] receiver
  delivers Messages::MessageReceivedEvent
  def message_received(event, receiver)
    @provider_account = event.provider
    @sender           = event.sender
    @recipient        = event.recipient
    @receiver         = receiver
    @message          = event.message
    @event            = event

    mail to: @receiver.email, subject: "New message from #{event.sender.name}"
  end

  # @param [Posts::PostCreatedEvent] event
  # @param [User] receiver
  delivers Posts::PostCreatedEvent, abilities: { manage: :forum }, hidden_onprem_multitenancy: true
  def post_created(event, receiver)
    @provider_account = event.provider
    @receiver         = receiver
    @post             = event.post
    @user             = event.try(:user)
    @account          = event.try(:account)
    @user_name        = @user.present? ? @user.informal_name : 'anonymous user'
    @event            = event

    mail to: @receiver.email, subject: "New forum post by #{@user_name}"
  end

  # @param [Reports::CsvDataExportEvent] event
  # @param [User] receiver
  delivers Reports::CsvDataExportEvent, hidden: true
  def csv_data_export(event, receiver)
    @provider_account = event.provider
    @receiver         = receiver
    export_service    = Reports::DataExportService.new(event.provider, event.type, event.period)
    @event            = event

    export_service.files.each do |name, file|
      attachments[name] = file
    end

    mail to: @receiver.email, subject: 'Your CSV export is ready'
  end

  # @param [Pdf::Report] report
  # @param [User] receiver
  delivers Reports::DailyReportEvent
  def daily_report(report, receiver)
    pdf_report_mail(report, receiver, :daily_report)
  end

  # @param [Pdf::Report] report
  # @param [User] receiver
  delivers Reports::WeeklyReportEvent
  def weekly_report(report, receiver)
    pdf_report_mail(report, receiver, :weekly_report)
  end

  # @param [Services::ServiceDeletedEvent] event
  # @param [User] received
  delivers Services::ServiceDeletedEvent
  def service_deleted(event, receiver)
    @provider_account = event.provider
    @receiver         = receiver
    @service_name     = event.service_name
    @event            = event

    mail to: @receiver.email, subject: "Service #{@service_name} deleted"
  end

  protected

  def pdf_report_mail(report, receiver, mail_name)
    @provider_account = report.account
    @receiver         = receiver
    report_file       = File.read(report.report.path)
    report_name       = "report-#{report.service.name}.pdf"

    attachments[report_name] = report_file

    mail to: @receiver.email, subject: t_subject(mail_name, name: report.account.name)
  end

  def limit_mail(event, receiver, mail_name)
    @provider_account = event.provider
    @alert            = event.alert
    @account          = @alert.account
    @cinstance        = @alert.cinstance
    @receiver         = receiver
    @event            = event

    subject = t_subject(mail_name, name: @cinstance.name, message: @alert.message, level: @alert.level)

    mail to: @receiver.email, subject: subject
  end

  def default_url_options
    super.merge(host: provider_account.try!(:admin_domain))
  end

  def t_subject(key, options = {})
    I18n.t(key, { scope: 'mailers.notification_mailer.subject', raise: true }.merge(options))
  end

  private

  def event_to_header
    headers('X-SMTPAPI' => x_smtp_api_value)

    if event
      headers('Event-ID' => event.event_id)
    else
      logger_info('does not include Event-ID header')
    end
  end

  def x_smtp_api_value
    {
      unique_args: {
        event_name: event_name = event.try(:class).try(:name),
        event_id: event.try(:event_id),
        user_id: receiver.try(:id),
        account_id: provider_account.try(:id)
      },
      category: [
        'notification',
        event_name.try(:underscore)
      ].compact,
    }.to_json
  end

  def logger_info(message)
    Rails.logger.info("[#{self.class.name}] #{action_name} #{message}")
  end
end
