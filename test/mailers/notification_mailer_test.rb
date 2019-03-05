require 'test_helper'

class NotificationMailerTest < ActionMailer::TestCase
  FakeContract = Struct.new(:old_plan, :plan, :provider_account, :service, :account, :issuer)

  include CinstancesHelper

  def test_event_to_header
    event = Invoices::InvoicesToReviewEvent.create(provider)
    mail  = NotificationMailer.invoices_to_review(event, receiver)

    field = mail.header['Event-ID']

    assert field
    assert_equal field.value, event.event_id
  end

  def test_x_smtp_header
    event = Invoices::InvoicesToReviewEvent.create(provider)
    user = receiver
    mail  = NotificationMailer.invoices_to_review(event, user)
    field = mail.header['X-SMTPAPI']

    assert field
    json = JSON.parse(field.value)

    assert_includes json['category'], 'notification'
    assert_includes json['category'], 'invoices/invoices_to_review_event'

    unique_args = json['unique_args']

    assert_equal event.event_id, unique_args['event_id']
    assert_equal 'Invoices::InvoicesToReviewEvent', unique_args['event_name']

    assert_equal user.id, unique_args['user_id']
    assert_equal provider.id, unique_args['account_id']
  end

  def test_application_created
    FieldsDefinition.create!(account: provider, name: 'LALA', target: 'Account', label: 'foo')
    application = FactoryBot.create(:cinstance, name: 'Bob app')
    service     = application.service
    user        = FactoryBot.create(:simple_user, first_name: 'Some Gal')
    event       = Applications::ApplicationCreatedEvent.create(application, user)
    mail        = NotificationMailer.application_created(event, receiver)

    assert_equal "Bob app created on #{service.name}", mail.subject
    assert_equal ['admin@example.com'], mail.to

    [mail.html_part.body, mail.text_part.body].each do |body|
      assert_match 'Dear Foobar Admin', body.encoded
      assert_match "A new application subscribed to the #{application.plan.name} plan on the #{service.name} service of the #{application.account.name} account.", body.encoded
      assert_match 'Application details:', body.encoded
      cinstance_url = Rails.application.routes.url_helpers.admin_service_application_url(service, application,
                                                                                         host: service.account.admin_domain)
      assert_match cinstance_url, body.encoded

      assert_html_email(mail) do
        assert_select 'li', text: 'Name: Bob app'
        assert_select 'li', text: 'Description: not provided by user'
      end
    end
  end

  def test_account_created
    provider = FactoryBot.create(:simple_provider)
    FieldsDefinition.create!(account: provider, name: 'org_name', target: 'Account', label: 'foo')
    account = FactoryBot.create(:simple_account, provider_account: provider)
    user  = FactoryBot.build_stubbed(:simple_user, first_name: 'Some Gal', account: account)
    event = Accounts::AccountCreatedEvent.create(account, user)
    mail  = NotificationMailer.account_created(event, receiver)

    assert_equal "#{user.informal_name} from #{account.name} signed up", mail.subject
    assert_equal [receiver.email], mail.to

    [mail.html_part.body, mail.text_part.body].each do |body|
      assert_match 'Dear Foobar Admin', body.encoded
      assert_match /Some Gal from \w+ has signed-up for:/, mail.body.encoded
    end

    assert_html_email(mail) do
      assert_select 'li', text: "foo: #{account.name}"
    end

    account.stubs(:approval_required?).returns(true)
    mail = NotificationMailer.account_created(event, receiver)

    assert_match 'Approve/ Reject application', mail.html_part.body.encoded

    account.stubs(:approval_required?).returns(false)
    mail = NotificationMailer.account_created(event, receiver)

    assert_match 'View new signup in your 3scale Admin Portal', mail.html_part.body.encoded

    assert_html_email(mail) do
      assert_select 'li', text: "foo: #{account.name}"

      account.defined_fields.each do |field|
        assert_select 'li', text: "#{account.field_label(field.name)}: #{account.field_value(field.name)}"
      end
    end
  end

  def test_limit_violation_reached_provider
    alert   = FactoryBot.build_stubbed(:limit_violation, id: 2, cinstance: application, message: 'Traffic')
    service = application.service
    event   = Alerts::LimitViolationReachedProviderEvent.create(alert)
    mail    = NotificationMailer.limit_violation_reached_provider(event, receiver)

    assert_equal "Application #{application.name} limit violation - usage of " \
                 "#{alert.message} is above #{alert.level}%", mail.subject
    assert_equal [receiver.email], mail.to
    assert_match /View application usage here/, mail.html_part.body.encoded

    [mail.html_part.body, mail.text_part.body].each do |body|
      assert_match 'Dear Foobar Admin', body.encoded
      assert_match "Application #{application.name} of your client #{application.user_account.name}", body.encoded
      assert_match "is above #{alert.level}% limit utilization of #{alert.message}.", body.encoded
      cinstance_url = Rails.application.routes.url_helpers.admin_service_application_url(service, application,
                                                                                         host: service.account.admin_domain)
      assert_match cinstance_url, body.encoded
    end
  end

  def test_limit_alert_reached_provider
    alert   = FactoryBot.build_stubbed(:limit_violation, id: 2, cinstance: application, message: 'Traffic')
    service = application.service
    event   = Alerts::LimitAlertReachedProviderEvent.create(alert)
    mail    = NotificationMailer.limit_alert_reached_provider(event, receiver)

    assert_equal "Application #{application.name} limit alert - usage of " \
                 "#{alert.message} is above #{alert.level}%", mail.subject
    assert_equal [receiver.email], mail.to
    assert_match /View application usage here/, mail.html_part.body.encoded

    [mail.html_part.body, mail.text_part.body].each do |body|
      assert_match 'Dear Foobar Admin', body.encoded
      assert_match "Application #{application.name} of your client #{application.user_account.name}", body.encoded
      assert_match "is above #{alert.level}% limit utilization of #{alert.message}.", body.encoded
      cinstance_url = Rails.application.routes.url_helpers.admin_service_application_url(service, application,
                                                                                         host: service.account.admin_domain)
      assert_match cinstance_url, body.encoded
    end
  end

  def test_unsuccessfully_charged_invoice_provider
    buyer   = FactoryBot.build_stubbed(:simple_buyer, name: 'Alexander')
    invoice = FactoryBot.build_stubbed(:invoice, id: 1, provider_account: provider,
                                                  state: 'created', buyer_account: buyer)
    event   = Invoices::UnsuccessfullyChargedInvoiceProviderEvent.create(invoice)
    mail    = NotificationMailer.unsuccessfully_charged_invoice_provider(event, receiver)

    assert_equal "#{buyer.name}'s payment has failed", mail.subject
    assert_equal [receiver.email], mail.to

    [mail.html_part.body, mail.text_part.body].each do |body|
      assert_match 'Dear Foobar Admin', body.encoded
      assert_match "the credit card payment for #{buyer.name} failed", body.encoded
    end
  end

  def test_account_plan_change_requested
    plan     = FactoryBot.build_stubbed(:simple_account_plan, id: 1)
    plan_2   = FactoryBot.build_stubbed(:simple_account_plan, id: 2)
    provider = FactoryBot.build_stubbed(:simple_provider, id: 3)
    account  = FactoryBot.build_stubbed(:simple_buyer, id: 4, name: 'Alex',
                                                        bought_account_plan: plan_2, provider_account: provider)
    user     = FactoryBot.build_stubbed(:simple_user, account: account)
    event    = Accounts::AccountPlanChangeRequestedEvent.create(account, user, plan)
    mail     = NotificationMailer.account_plan_change_requested(event, receiver)

    assert_equal "#{account.name} has requested a plan change", mail.subject
    assert_equal [receiver.email], mail.to

    [mail.html_part.body, mail.text_part.body].each do |body|
      assert_match 'Dear Foobar Admin', body.encoded
      assert_match "#{user.informal_name} from #{account.name} has requested to change", body.encoded
      assert_match "their account plan from #{plan_2.name} to #{plan.name}", body.encoded
    end
  end

  def test_service_plan_change_requested
    service          = FactoryBot.build_stubbed(:simple_service, name: 'Foo Service')
    current_plan     = FactoryBot.build_stubbed(:simple_service_plan, issuer: service, name: 'Plan 1')
    requested_plan   = FactoryBot.build_stubbed(:simple_service_plan, issuer: service, name: 'Plan 2')
    user             = FactoryBot.build_stubbed(:simple_user, account: account)
    account          = FactoryBot.build_stubbed(:simple_buyer, name: 'SimpleCompany', provider_account: provider)
    service_contract = FactoryBot.build_stubbed(:simple_service_contract, plan: current_plan, user_account: account)
    event            = Services::ServicePlanChangeRequestedEvent.create(service_contract, user, requested_plan)
    mail             = NotificationMailer.service_plan_change_requested(event, receiver)

    assert_equal 'Action needed: service subscription change request by SimpleCompany.', mail.subject
    assert_equal [receiver.email], mail.to
    assert_equal event.event_id, mail.header['Event-ID'].value

    [mail.html_part.body, mail.text_part.body].each do |body|
      assert_match 'Dear Foobar Admin', body.encoded
      assert_match "#{user.informal_name} from SimpleCompany has requested to change their Foo Service", body.encoded
      assert_match 'service subscription from Plan 1 to Plan 2.', body.encoded
      assert_match url_helpers.admin_buyers_account_service_contracts_url(account, host: provider.admin_domain), body.encoded
    end
  end

  def test_invoices_to_review
    provider = FactoryBot.build_stubbed(:simple_provider, id: 1)
    event    = Invoices::InvoicesToReviewEvent.create(provider)
    mail     = NotificationMailer.invoices_to_review(event, receiver)

    assert_equal 'Action needed: review invoices', mail.subject
    assert_equal [receiver.email], mail.to
    assert_match 'Review invoices now', mail.html_part.body.encoded

    [mail.html_part.body, mail.text_part.body].each do |body|
      assert_match 'Dear Foobar Admin', body.encoded
    end
  end

  def test_expired_credit_card_provider
    provider = FactoryBot.build_stubbed(:simple_provider, id: 1)
    account  = FactoryBot.build_stubbed(:simple_buyer, id: 2, name: 'Alex', provider_account: provider)
    event    = Accounts::ExpiredCreditCardProviderEvent.create(account)
    mail     = NotificationMailer.expired_credit_card_provider(event, receiver)

    assert_equal "#{account.name}’s credit card is due to expire", mail.subject
    assert_equal [receiver.email], mail.to

    [mail.html_part.body, mail.text_part.body].each do |body|
      assert_match 'Dear Foobar Admin', body.encoded
      assert_match "he credit card from #{account.name} is about to expire.", body.encoded
    end
  end

  def test_cinstance_cancellation
    event = Cinstances::CinstanceCancellationEvent.create(application)
    mail  = NotificationMailer.cinstance_cancellation(event, receiver)

    assert_equal "Application #{application.name} has been deleted", mail.subject
    assert_equal [receiver.email], mail.to


    [mail.html_part.body, mail.text_part.body].each do |body|
      assert_match "#{application.name} on application plan #{application.plan.name}", body.encoded
      assert_match "#{application.service.name} for developer account #{application.account.name}", body.encoded
    end
  end

  def test_service_contract_cancellation
    account  = FactoryBot.build_stubbed(:simple_buyer, name: 'Alex')
    contract = FactoryBot.build_stubbed(:service_contract, user_account: account)
    contract.stubs(:provider_account).returns(FactoryBot.build_stubbed(:simple_provider))
    event    = ServiceContracts::ServiceContractCancellationEvent.create(contract)
    mail     = NotificationMailer.service_contract_cancellation(event, receiver)

    assert_equal "#{account.name} has cancelled their subscription", mail.subject
    assert_equal [receiver.email], mail.to

    [mail.html_part.body, mail.text_part.body].each do |body|
      assert_match "The subscription of #{account.name} to plan", body.encoded
    end
  end

  def test_service_contract_created
    service  = FactoryBot.build_stubbed(:simple_service)
    plan     = FactoryBot.build_stubbed(:service_plan, issuer: service)
    account  = FactoryBot.build_stubbed(:simple_buyer, name: 'Alex')
    contract = FactoryBot.build_stubbed(:service_contract, plan: plan, user_account: account)
    contract.stubs(:provider_account).returns(FactoryBot.build_stubbed(:simple_provider))
    user     = FactoryBot.build_stubbed(:simple_user, account: account)
    event    = ServiceContracts::ServiceContractCreatedEvent.create(contract, user)
    mail     = NotificationMailer.service_contract_created(event, receiver)

    assert_equal "#{account.name} has subscribed to your service #{service.name}", mail.subject
    assert_equal [receiver.email], mail.to

    [mail.html_part.body, mail.text_part.body].each do |body|
      assert_match 'Dear Foobar Admin', body.encoded
    end

    plan.stubs(:approval_required?).returns(true)
    mail = NotificationMailer.service_contract_created(event, receiver)

    assert_match 'Approve/ Reject subscription', mail.html_part.body.encoded

    plan.stubs(:approval_required?).returns(false)
    mail = NotificationMailer.service_contract_created(event, receiver)

    assert_match 'View account', mail.html_part.body.encoded
  end

  def test_cinstance_expired_trial
    account   = FactoryBot.build_stubbed(:simple_buyer, name: 'Alex')
    plan      = FactoryBot.build_stubbed(:simple_application_plan, name: 'planLALA')
    cinstance = FactoryBot.build_stubbed(:simple_cinstance, user_account: account, plan: plan, name: 'LALA')
    service   = cinstance.service
    event     = Cinstances::CinstanceExpiredTrialEvent.create(cinstance)
    mail      = NotificationMailer.cinstance_expired_trial(event, receiver)

    assert_equal "Alex's trial of the LALA application on the planLALA has expired", mail.subject
    assert_equal [receiver.email], mail.to

    [mail.html_part.body, mail.text_part.body].each do |body|
      assert_match 'Dear Foobar Admin', body.encoded
      assert_match "Alex's trial of the LALA application on the planLALA has expired.", body.encoded
      assert_match url_helpers.admin_service_application_url(service, cinstance, host: service.provider.admin_domain), body.encoded
    end
  end

  def test_service_contract_plan_changed
    old_plan = FactoryBot.build_stubbed(:simple_service_plan, name: 'Plan 1')
    new_plan = FactoryBot.build_stubbed(:simple_service_plan, name: 'Plan 2')
    service  = FactoryBot.build_stubbed(:simple_service, name: 'Service 1')
    user     = FactoryBot.build_stubbed(:simple_user, account: account)
    contract = FakeContract.new(old_plan, new_plan, provider, service, account, issuer: service)
    event    = ServiceContracts::ServiceContractPlanChangedEvent.create(contract, user)
    mail     = NotificationMailer.service_contract_plan_changed(event, receiver)

    assert_equal "#{account.name} has changed subscription to #{new_plan.name}", mail.subject
    assert_equal [receiver.email], mail.to

    [mail.html_part.body, mail.text_part.body].each do |body|
      assert_match 'Dear Foobar Admin', body.encoded
      assert_match "Previous plan: #{old_plan.name}", body.encoded
      assert_match "New plan: #{new_plan.name}", body.encoded
      assert_match "The subscription of #{account.name} on your service #{service.name} has been changed to plan #{new_plan.name}.", body.encoded
    end
  end

  def test_plan_downgraded
    service  = FactoryBot.build_stubbed(:simple_service, name: 'Service 1', account: provider)
    new_plan = FactoryBot.build_stubbed(:simple_application_plan, name: '1', issuer: service)
    old_plan = FactoryBot.build_stubbed(:simple_application_plan, name: '2')
    contract = FactoryBot.build_stubbed(:simple_service_contract, user_account: account)
    event    = Plans::PlanDowngradedEvent.create(new_plan, old_plan, contract)
    mail     = NotificationMailer.plan_downgraded(event, receiver)

    assert_equal "#{account.name} has downgraded", mail.subject
    assert_equal [receiver.email], mail.to

    [mail.html_part.body, mail.text_part.body].each do |body|
      assert_match 'Dear Foobar Admin', body.encoded
      assert_match "#{account.name} has downgraded", body.encoded
      assert_match "to #{new_plan.name} plan (from #{old_plan.name}).", body.encoded
    end
  end

  def test_unsuccessfully_charged_invoice_final_provider
    buyer   = FactoryBot.build_stubbed(:simple_buyer, name: 'Alexander')
    invoice = FactoryBot.build_stubbed(:invoice, id: 1, provider_account: provider,
                                        state: 'created', buyer_account: buyer)
    event   = Invoices::UnsuccessfullyChargedInvoiceFinalProviderEvent.create(invoice)
    mail    = NotificationMailer.unsuccessfully_charged_invoice_final_provider(event, receiver)

    assert_equal "#{buyer.name}'s payment has failed without retry", mail.subject
    assert_equal [receiver.email], mail.to

    [mail.html_part.body, mail.text_part.body].each do |body|
      assert_match 'Dear Foobar Admin', body.encoded
      assert_match "the credit card payment for #{buyer.name} failed 3 times", body.encoded
    end
  end

  def test_account_deleted
    buyer = FactoryBot.build_stubbed(:simple_buyer, name: 'Supertramp', provider_account: provider)
    event = Accounts::AccountDeletedEvent.create(buyer)
    mail  = NotificationMailer.account_deleted(event, receiver)

    assert_equal 'Account Supertramp deleted', mail.subject
    assert_equal [receiver.email], mail.to

    [mail.html_part.body, mail.text_part.body].each do |body|
      assert_match 'Dear Foobar Admin', body.encoded
      assert_match "Supertramp has been deleted", body.encoded
      assert_match url_helpers.admin_buyers_accounts_path, body.encoded
    end
  end

  def test_cinstance_plan_changed
    buyer     = FactoryBot.build_stubbed(:simple_buyer, name: 'Supertramp', provider_account: provider)
    user      = FactoryBot.build_stubbed(:simple_user, account: buyer, first_name: 'Alex')
    old_plan  = FactoryBot.build_stubbed(:simple_application_plan, name: 'Old plan')
    cinstance = FactoryBot.build_stubbed(:simple_cinstance, name: 'Some Name', user_account: buyer)

    cinstance.expects(:old_plan).returns(old_plan)

    event = Cinstances::CinstancePlanChangedEvent.create(cinstance, user)
    mail  = NotificationMailer.cinstance_plan_changed(event, receiver)

    assert_equal "Application Some Name has changed to plan #{cinstance.plan.name}", mail.subject
    assert_equal [receiver.email], mail.to

    [mail.html_part.body, mail.text_part.body].each do |body|
      assert_match "Application: #{cinstance.name}", body.encoded
      assert_match "Developer: #{buyer.name}", body.encoded
      assert_match "Previous plan: #{old_plan.name}", body.encoded
      assert_match "Current plan: #{cinstance.plan.name}", body.encoded
      assert_match "Application #{cinstance.name} has changed to plan #{cinstance.plan.name}.", body.encoded
      cinstance_url = Rails.application.routes.url_helpers.admin_service_application_url(cinstance.service, cinstance,
                                                                                         host: cinstance.service.account.admin_domain)
      assert_match cinstance_url, body.encoded
    end
  end

  def test_message_received
    message   = FactoryBot.build_stubbed(:message)
    recipient = FactoryBot.build_stubbed(:received_message, message: message, receiver: provider)
    recipient.id = 42
    event     = Messages::MessageReceivedEvent.create(message, recipient)
    mail      = NotificationMailer.message_received(event, receiver)

    assert_equal "New message from #{message.sender.name}", mail.subject
    assert_equal [receiver.email], mail.to

    url = url_helpers.provider_admin_messages_inbox_url(recipient, host: provider.admin_domain)

    [mail.html_part.body, mail.text_part.body].each do |body|
      assert_match "You have a new message from #{message.sender.name}.", body.encoded
      assert_match url, body.encoded
    end
  end

  def test_post_created
    forum = FactoryBot.build_stubbed(:forum, account: provider)
    topic = FactoryBot.build_stubbed(:topic, forum: forum, permalink: 'alex')
    post  = FactoryBot.build_stubbed(:post, forum: forum, topic: topic)
    event = Posts::PostCreatedEvent.create(post)
    mail  = NotificationMailer.post_created(event, receiver)

    assert_equal [[:manage, :forum]], NotificationMailer.required_abilities[:post_created]

    assert_equal "New forum post by #{post.user.informal_name}", mail.subject
    assert_equal [receiver.email], mail.to

    [mail.html_part.body, mail.text_part.body].each do |body|
      assert_match "#{post.user.informal_name} from #{post.user.account.name}", body.encoded
    end

    # anonymous user
    post.user = nil

    no_user_event = Posts::PostCreatedEvent.create(post)
    not_user_mail = NotificationMailer.post_created(no_user_event, receiver)

    assert_equal 'New forum post by anonymous user', not_user_mail.subject

    [not_user_mail.html_part.body, not_user_mail.text_part.body].each do |body|
      assert_match 'Anonymous user has posted', body.encoded
    end
  end

  def test_csv_data_export
    user  = FactoryBot.build_stubbed(:simple_user, account: account)
    event = Reports::CsvDataExportEvent.create(provider, user, 'users', 'week')
    mail  = NotificationMailer.csv_data_export(event, receiver)

    assert_equal 'Your CSV export is ready', mail.subject
    assert_equal [receiver.email], mail.to

    assert mail.attachments
    assert_equal mail.attachments.count, 1
    assert_match "3scale-report-#{provider.name}", mail.attachments.first.filename

    [mail.html_part.body, mail.text_part.body].each do |body|
      assert_match 'Your CSV export is ready', body.encoded
    end

    # csv data export notification is not visible in UI
    NotificationMailer.hidden_notifications.include?(:csv_data_export)
  end

  def test_daily_report
    service = FactoryBot.create(:simple_service)
    report  = Pdf::Report.new(provider, service, period: 'day').generate
    mail    = NotificationMailer.daily_report(report, receiver)

    assert_equal "#{provider.name} daily report", mail.subject

    assert mail.attachments
    assert_equal mail.attachments.count, 1
    assert_match "report-#{service.name}.pdf", mail.attachments.first.filename

    [mail.html_part.body, mail.text_part.body].each do |body|
      assert_match 'Please find attached your API Usage Report', body.encoded
    end
  end

  def test_weekly_report
    service = FactoryBot.create(:simple_service)
    report  = Pdf::Report.new(provider, service, period: 'week').generate
    mail    = NotificationMailer.weekly_report(report, receiver)

    assert_equal "#{provider.name} weekly report", mail.subject

    assert mail.attachments
    assert_equal mail.attachments.count, 1
    assert_match "report-#{service.name}.pdf", mail.attachments.first.filename

    [mail.html_part.body, mail.text_part.body].each do |body|
      assert_match 'Please find attached your API Usage Report', body.encoded
    end
  end

  def test_service_deleted
    persisted_provider = FactoryBot.create(:simple_provider)
    service = FactoryBot.build_stubbed(:simple_service, account: persisted_provider)
    event   = Services::ServiceDeletedEvent.create(service)
    mail    = NotificationMailer.service_deleted(event, receiver)

    assert_equal "Service #{service.name} deleted", mail.subject

    [mail.html_part.body, mail.text_part.body].each do |body|
      assert_match "The service #{service.name} has been deleted.", body.encoded
      assert_match url_helpers.provider_admin_dashboard_url(host: persisted_provider.admin_domain), body.encoded
    end
  end

  def test_application_plan_change_requested
    provider    = FactoryBot.build_stubbed(:simple_provider, id: 3)
    account     = FactoryBot.build_stubbed(:simple_buyer, id: 4, name: 'Boo Account', provider_account: provider)
    service     = FactoryBot.build_stubbed(:simple_service, account: provider)
    plan        = FactoryBot.build_stubbed(:simple_application_plan, id: 1, issuer: service)
    plan_2      = FactoryBot.build_stubbed(:simple_application_plan, id: 2, issuer: service)
    user        = FactoryBot.build_stubbed(:simple_user, account: account, username: 'Bob')
    application = FactoryBot.build_stubbed(:simple_cinstance, plan: plan, user_account: account, service: service, name: 'Boo App')
    event       = Applications::ApplicationPlanChangeRequestedEvent.create(application, user, plan_2)
    mail        = NotificationMailer.application_plan_change_requested(event, receiver)

    assert_equal "Action required: Bob from Boo Account requested an app plan change", mail.subject
    assert_equal [receiver.email], mail.to
    assert_equal event.event_id, mail.header['Event-ID'].value

    [mail.html_part.body, mail.text_part.body].each do |body|
      assert_match "Dear Foobar Admin", body.encoded
      assert_match "Bob from Boo Account has requested to change", body.encoded
      assert_match "the plan for one of their applications", body.encoded
      assert_match "Application: Boo App", body.encoded
      assert_match "Current plan: #{plan.name}", body.encoded
      assert_match "Requested plan: #{plan_2.name}", body.encoded
      assert_match url_helpers.admin_service_application_url(application.service, application, host: application.service.provider.admin_domain), body.encoded
    end
  end

  private

  def receiver
    FactoryBot.build_stubbed(:simple_user, first_name: 'Foobar Admin', email: 'admin@example.com')
  end

  def account
    @_account ||= FactoryBot.build_stubbed(:simple_account, provider_account: provider)
  end

  def provider
    @_provider ||= FactoryBot.build_stubbed(:simple_provider)
  end

  def application
    @_application ||= FactoryBot.build_stubbed(:simple_cinstance, name: 'Some Name')
  end

  def url_helpers
    Rails.application.routes.url_helpers
  end

  def assert_html_email(delivery, &block)
    (delivery.parts.empty? ? [delivery] : delivery.parts).each do |part|
      if part['Content-Type'].to_s =~ /^text\/html\W/
        root = Nokogiri::HTML::Document.parse(part.body.to_s)
        assert_select root, ':root', &block
      end
    end
  end
end
