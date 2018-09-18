class MailPreview < MailView
  FakeContract = Struct.new(:old_plan, :plan, :provider_account, :service, :account, :name)

  def application_created
    event = Applications::ApplicationCreatedEvent.create(Cinstance.last, User.last)

    NotificationMailer.application_created(event, receiver)
  end

  def application_plan_change_requested
    event = Applications::ApplicationPlanChangeRequestedEvent.create(ApplicationContract.last, User.last, Plan.last)

    NotificationMailer.application_plan_change_requested(event, receiver)
  end

  def cinstance_expired_trial
    event = Cinstances::CinstanceExpiredTrialEvent.create(Cinstance.last)

    NotificationMailer.cinstance_expired_trial(event, receiver)
  end

  def service_contract_plan_changed
    plans    = ServicePlan.last(2)
    contract = FakeContract.new(plans.first, plans.second, Account.providers.last, Service.last, Account.last, '1')
    event    = ServiceContracts::ServiceContractPlanChangedEvent.create(
      contract, User.last
    )

    NotificationMailer.service_contract_plan_changed(event, receiver)
  end

  def plan_downgraded
    plans = ApplicationPlan.last(2)
    event = Plans::PlanDowngradedEvent.create(plans.first, plans.second, Contract.last)

    NotificationMailer.plan_downgraded(event, receiver)
  end

  def account_created
    buyer = Account.buyers.having('count(cinstances.id) > 1').joins(:bought_service_contracts).group(:id).first!
    event = Accounts::AccountCreatedEvent.create(buyer, User.last)

    NotificationMailer.account_created(event, receiver)
  end

  def limit_violation_reached_provider
    event = Alerts::LimitViolationReachedProviderEvent.create(Alert.last)

    NotificationMailer.limit_violation_reached_provider(event, receiver)
  end

  def limit_alert_reached_provider
    event = Alerts::LimitViolationReachedProviderEvent.create(Alert.last)

    NotificationMailer.limit_alert_reached_provider(event, receiver)
  end

  def unsuccessfully_charged_invoice_provider
    event = Invoices::UnsuccessfullyChargedInvoiceProviderEvent.create(Invoice.last)

    NotificationMailer.unsuccessfully_charged_invoice_provider(event, receiver)
  end

  def account_plan_change_requested
    event = Accounts::AccountPlanChangeRequestedEvent.create(Account.last, User.last, Plan.last)

    NotificationMailer.account_plan_change_requested(event, receiver)
  end

  def service_plan_change_requested
    event = Services::ServicePlanChangeRequestedEvent.create(ServiceContract.last, User.last, Plan.last)

    NotificationMailer.service_plan_change_requested(event, receiver)
  end

  def invoices_to_review
    event = Invoices::InvoicesToReviewEvent.create(Account.providers.last)

    NotificationMailer.invoices_to_review(event, receiver)
  end

  def expired_credit_card
    event = Accounts::ExpiredCreditCardProviderEvent.create(Account.buyers.last)

    NotificationMailer.expired_credit_card(event, receiver)
  end

  def cinstance_cancellation
    event = Cinstances::CinstanceCancellationEvent.create(Cinstance.last)

    NotificationMailer.cinstance_cancellation(event, receiver)
  end

  def service_contract_cancellation
    event = ServiceContracts::ServiceContractCancellationEvent.create(ServiceContract.last)

    NotificationMailer.service_contract_cancellation(event, receiver)
  end

  def service_contract_created
    event = ServiceContracts::ServiceContractCreatedEvent.create(ServiceContract.last, User.last)

    NotificationMailer.service_contract_created(event, receiver)
  end

  def account_deleted
    event = Accounts::AccountDeletedEvent.create(Account.buyers.last)

    NotificationMailer.account_deleted(event, receiver)
  end

  def cinstance_plan_changed
    plans     = ServicePlan.last(2)
    cinstance = FakeContract.new(plans.first, plans.second, Account.providers.last, Service.last, Account.last, '1')
    event = Cinstances::CinstancePlanChangedEvent.create(cinstance, User.last)

    NotificationMailer.cinstance_plan_changed(event, receiver)
  end

  def message_received
    event = Messages::MessageReceivedEvent.create(Message.last, MessageRecipient.last)

    NotificationMailer.message_received(event, receiver)
  end

  def post_created_registered_user
    event = Posts::PostCreatedEvent.create(Post.where.not(user_id: nil).last)

    NotificationMailer.post_created(event, receiver)
  end

  def post_created_anonymous_user
    event = Posts::PostCreatedEvent.create(Post.where(user_id: nil).last)

    NotificationMailer.post_created(event, receiver)
  end

  def csv_data_export
    event = Reports::CsvDataExportEvent.create(Account.providers.last, User.last, 'users', 'week')

    NotificationMailer.csv_data_export(event, receiver)
  end

  def weekly_report
    report = Pdf::Report.new(Account.providers.last, Service.last, period: 'week').generate

    NotificationMailer.daily_report(report, receiver)
  end

  def daily_report
    report = Pdf::Report.new(Account.providers.last, Service.last, period: 'day').generate

    NotificationMailer.daily_report(report, receiver)
  end

  private

  def receiver
    @_receiver ||= User.last
  end
end
