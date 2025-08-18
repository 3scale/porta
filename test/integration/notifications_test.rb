# frozen_string_literal: true

require 'test_helper'

class NotificationsTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  class TheMainTest < NotificationsTest
    def setup
      super
      ActionMailer::Base.deliveries = []

      @operation = SystemOperation.for('plan_change')
      @buyer_sender = FactoryBot.create(:buyer_account)
      @provider = FactoryBot.create(:provider_account)

      @message = Message.create!(sender: @buyer_sender,
                                 system_operation: @operation,
                                 to: [@provider],
                                 subject: 'hello',
                                 body: "what\'s up?")
      @provider_recipient = @message.recipients.first
    end

    test 'be sent to provider when no corresponding system operation object exists' do
      SystemOperation.delete_all
      @message.update(system_operation: nil)
      @message.reload
      PostOffice.message_notification(@message, @provider_recipient).deliver_now
      @email = ActionMailer::Base.deliveries.last
      expected = [@provider.admins.first.email]
      assert_same_elements @email.bcc, expected
    end
  end

  class NotifyTest < NotificationsTest
    def setup
      super
      @system_operation = SystemOperation.for('plan_change')

      buyer = FactoryBot.create(:buyer_account)
      provider = FactoryBot.create(:provider_account)

      @message = Message.create!(sender: buyer,
                                 to: provider,
                                 subject: 'Changed plan',
                                 body: "plan has changed",
                                 system_operation: @system_operation)
    end

    test "have an operation attribute" do
      assert_equal @system_operation, @message.system_operation
    end
  end

  class ApplicationCreationTest < NotificationsTest
    disable_transactional_fixtures!
    self.database_cleaner_strategy = :deletion
    self.database_cleaner_clean_with_strategy = :deletion

    def setup
      super
      @provider = FactoryBot.create(:provider_account)
      @admin = @provider.admins.first
      @admin.update(email: "provider-admin@example.com")
      @admin.notification_preferences.update(enabled_notifications: %i[application_created])

      @buyer = FactoryBot.create(:buyer_account, provider_account: @provider)
      @plan  = FactoryBot.create(:application_plan, issuer: @provider.default_service)
      ActionMailer::Base.deliveries.clear
    end

    test 'be notified' do
      with_sidekiq { @buyer.buy! @plan }

      notification = @provider.first_admin.notifications.find_by(system_name: :application_created)
      mail = ActionMailer::Base.deliveries.select { _1.header["Event-ID"].to_s == notification&.parent_event&.event_id }&.first

      assert_includes mail.to, @admin.email
    end
  end

  class AccountSignupOnConfirmationTest < NotificationsTest
    def setup
      super
      @provider = FactoryBot.create :provider_account
      @admin = @provider.admins.first
      @admin.update(email: "provider-admin@example.com")

      ActionMailer::Base.deliveries.clear
    end

    test 'notify buyer' do
      buyer = FactoryBot.create(:buyer_account, provider_account: @provider)
      perform_enqueued_jobs(only: ActionMailer::MailDeliveryJob) { buyer.make_pending! }

      assert_includes ActionMailer::Base.deliveries.map(&:to).flatten, buyer.first_admin.email
    end
  end

  class NotificationCategoriesTest < NotificationsTest
    disable_transactional_fixtures!
    self.database_cleaner_strategy = :deletion
    self.database_cleaner_clean_with_strategy = :deletion

    def setup
      super
      @provider = FactoryBot.create(:provider_account)
      @admin = @provider.admins.first
      @admin.update(email: "provider-admin@example.com")
      @admin.notification_preferences.update(enabled_notifications: %i[unsuccessfully_charged_invoice_provider])

      @buyer = FactoryBot.create(:buyer_account, provider_account: @provider)
      @invoice = FactoryBot.create(:invoice, provider_account: @provider, buyer_account: @buyer, state: :pending, currency: 'EUR')
      FactoryBot.create(:line_item, invoice: @invoice, cost: 50, quantity: 1)

      ActionMailer::Base.deliveries.clear
    end

    test 'user is not notified when the notification category is disabled' do
      with_sidekiq { @invoice.charge! }

      notification = @provider.first_admin.notifications.find_by(system_name: :unsuccessfully_charged_invoice_provider)
      mail = ActionMailer::Base.deliveries.select { _1.header["Event-ID"].to_s == notification&.parent_event&.event_id }&.first

      assert_nil mail
    end

    test 'user is notified when the notification category is enabled' do
      @provider.billing_strategy= FactoryBot.create(:postpaid_billing, numbering_period: 'monthly')
      @provider.save

      with_sidekiq { @invoice.charge! }

      notification = @provider.first_admin.notifications.find_by(system_name: :unsuccessfully_charged_invoice_provider)
      mail = ActionMailer::Base.deliveries.select { _1.header["Event-ID"].to_s == notification&.parent_event&.event_id }&.first

      assert_includes mail.to, @admin.email
    end
  end
end
