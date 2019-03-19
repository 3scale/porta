class Notifications::NewNotificationSystemMigration
  attr_reader :account

  def self.run!(account)
    new(account).migrate!
  end

  def initialize(account)
    @account = account
  end

  def notification_preferences
    default_preferences = NotificationPreferences.default_preferences

    return default_preferences unless enabled?

    migrated_preferences = system_operations.each_with_object({}) do |operation, preferences|
      rule = account.fetch_dispatch_rule(operation)

      equivalents_for(operation).each do |equivalent|
        preferences[equivalent] = rule.dispatch

        yield rule if block_given?
      end
    end

    default_preferences.merge(migrated_preferences)
  end

  def system_operations
    SystemOperation.order(:pos)
  end

  def enabled?
    account.provider? && account.provider_can_use?(:new_notification_system)
  end

  # @return [Boolean] should dispatch new notification
  def dispatch?(operation)
    !equivalents_for(operation).present?
  end

  # @param [SystemOperation] operation
  # @return [Array<String>] notification preferences equivalents
  # @return [nil] if there are no equivalents
  def equivalents_for(operation)
    equivalents = case operation.ref.to_sym
                  when :user_signup
                    :account_created
                  when :new_app
                    :application_created
                  when :new_contract
                    :service_contract_created
                  when :plan_change
                    %i[service_contract_plan_changed cinstance_plan_changed
                       cinstance_expired_trial].freeze
                  when :limit_alerts
                    %i[limit_alert_reached_provider limit_violation_reached_provider].freeze
                  when :cinstance_cancellation
                    :cinstance_cancellation
                  when :contract_cancellation
                    :service_contract_cancellation
                  when :plan_change_request
                    :account_plan_change_requested
                  when :new_message
                    :message_received
                  when :new_forum_post
                    :post_created
                  when :weekly_reports
                    :weekly_report
                  when :daily_reports
                    :daily_report
                  else
                    []
    end

    Array(equivalents)
  end

  def migrate!
    to_disable = []

    preferences = notification_preferences do |rule, _|
      to_disable << rule
    end

    Account.transaction do
      account.users.find_each do |user|
        user.notification_preferences.update_attributes!(preferences: preferences)

        Rails.logger.info("[#{self.class.name}] User #{user.email} has been migrated")
      end

      disable_old_notifications!(to_disable)
    end
  end

  private

  def disable_old_notifications!(rules)
    MailDispatchRule.where(id: rules).update_all(dispatch: false)
  end
end
