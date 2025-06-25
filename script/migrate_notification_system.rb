# frozen_string_literal: true

# Run it with rails runner, for example:
# $ bundle exec rails runner migrate_notification_system.rb

require 'progress_counter'

module MigrateNotificationSystem

  module_function

  # Notifications that didn't exist in the old system
  NEW_NOTIFICATIONS = %i[account_deleted application_plan_change_requested service_plan_change_requested
                       invoices_to_review plan_downgraded credit_card_unstore_failed expired_credit_card_provider
                       unsuccessfully_charged_invoice_provider unsuccessfully_charged_invoice_final_provider
                       csv_data_export service_deleted].freeze

  def scope
    # Active users, belonging to an active provider and without notification preferences, except impersonation admins
    User.active
        .joins(:account)
        .includes(:notification_preferences)
        .where({ account: { provider: true, master: nil, state: 'approved' }, notification_preferences: { id: nil }})
        .where.not( username: ThreeScale.config.impersonation_admin[:username])
  end

  def call
    total = scope.count
    puts "Users count: #{total}"

    users = scope.find_each

    each_with_progress_counter(users, total) do |user|
      preferences = migrated_preferences(user)
      user.notification_preferences.update!(preferences:)

      # puts
      # puts "----------------------"
      # puts "Provider: #{user.account.id}, #{user.account.name}"
      # puts "User: #{user.id}, #{user.username}"
      # puts "Previous preferences: #{user.notification_preferences.preferences.symbolize_keys}"
      # puts "Migrated preferences: #{preferences}"
      # puts "Changed? #{user.notification_preferences.preferences.symbolize_keys != preferences}"
      # puts
    end
    puts # To show the terminal prompt in the next line
  end

  def each_with_progress_counter(enumerable, count)
    progress = ProgressCounter.new(count)
    enumerable.each do |element|
      progress.call
      yield element
    end
  end

  def migrated_preferences(user)
    default_preferences = NotificationPreferences.default_preferences

    migrated_preferences = provider_preferences(user.account)

    default_preferences.merge(new_preferences_disabled).merge(migrated_preferences)
  end

  def provider_preferences(provider)
    Rails.cache.fetch("provider/#{provider.id}/migrated_notification_preferences", expires_in: 1.day) do
      SystemOperation.order(:pos).each_with_object({}) do |operation, preferences|
        rule = fetch_dispatch_rule(operation, provider)

        equivalents_for(operation).each do |equivalent|
          preferences[equivalent] = rule.dispatch
        end
      end
    end
  end

  def new_preferences_disabled
    NotificationPreferences.preferences_to_hash(NEW_NOTIFICATIONS, value: false)
  end

  # @param [SystemOperation] operation
  def fetch_dispatch_rule(operation, account)
    MailDispatchRule.find_or_initialize_by(system_operation: operation, account:) do |m|
      m.dispatch = false if %w[weekly_reports daily_reports new_forum_post].include?(operation.ref)
    end
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
end

MigrateNotificationSystem.call
