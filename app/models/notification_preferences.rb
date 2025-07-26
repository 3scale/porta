class NotificationPreferences < ApplicationRecord
  belongs_to :user, inverse_of: :notification_preferences

  validates :user, presence: true
  validate :preferences_valid?
  serialize :preferences, coder: JSON

  after_initialize :set_defaults

  def self.preferences_to_hash(list, value:)
    list.reject(&:empty?).map { |method| [method.to_sym, value] }.to_h
  end

  class_attribute :disabled_by_default, :enabled_by_default,
                  :default_preferences, :available_notifications,
                  :hidden_notifications, instance_writer: false

  self.available_notifications = NotificationMailer.available_notifications.freeze

  self.disabled_by_default  = %i[application_created cinstance_cancellation cinstance_expired_trial
                                 cinstance_plan_changed account_created account_deleted
                                 unsuccessfully_charged_invoice_provider service_contract_cancellation
                                 service_contract_created service_contract_plan_changed plan_downgraded service_deleted
                                 post_created weekly_report daily_report].freeze
  self.enabled_by_default   = (available_notifications - disabled_by_default).freeze
  self.hidden_notifications = NotificationMailer.hidden_notifications.freeze

  enabled = preferences_to_hash(enabled_by_default, value: true)
  disabled = preferences_to_hash(disabled_by_default, value: false)

  self.default_preferences = enabled.merge(disabled).freeze

  def preferences=(preferences)
    super Hash(preferences).stringify_keys
  end

  # "patches" the notification preferences, setting only the preferences that appear in the hash,
  # to the corresponding values. The other preferences remain unchanged.
  # @param [Hash] updated_preferences - new values for the preferences
  # @example Update preferences
  #   preferences.update(new_preferences: { account_created: true, limit_alert_reached_provider: false })
  # Valid values are: true, false, "true", "false". Other values (including empty) will not pass validation.
  def new_preferences=(updated_preferences = {})
    transformed = updated_preferences.transform_values { transform_boolean(_1) }
    self.preferences = preferences.merge(transformed)
  end

  def include?(preference)
    enabled_notifications.include?(preference.to_s)
  end

  # @return [Array<String>] an Array of enabled notifications for formtastic as it can't work with Sets
  def enabled_notifications
    enabled_preferences = preferences.select { |_, v| v }.keys
    (available_notifications & enabled_preferences).to_a
  end

  # @return [Array<String>]
  def available_notifications
    Set.new(self.class.available_notifications.map(&:to_s))
  end

  # @return [Array<String>]
  def default_preferences
    self.class.default_preferences.stringify_keys
  end

  # Sets the notification preferences:
  # - enables all preferences, included in the argument
  # - disables all other preferences, not included in the argument
  # @param [Array<String>] preferences - list of enabled preferences
  def enabled_notifications=(preferences)
    enabled  = preferences_to_hash(preferences, value: true).stringify_keys
    hidden   = preferences_to_hash(hidden_notifications, value: true)
    disabled = preferences_to_hash(available_notifications, value: false)

    self.preferences = disabled.merge(enabled).merge(hidden)
  end

  # @return [Hash<String,Boolean>]
  def preferences
    Hash(super).reverse_merge(default_preferences)
  end

  protected

  def set_defaults
    return if persisted?
    self.preferences ||= default_preferences
  end

  delegate :preferences_to_hash, to: :class

  def transform_boolean(value)
    case value
    when "false"
      false
    when "true"
      true
    else
      value
    end
  end

  def preferences_valid?
    preferences.each_pair do |key,value|
      errors.add(:preferences, :invalid_value, key: key) unless [true, false].include? value
      errors.add(:preferences, :invalid_key, key: key) unless available_notifications.include? key.to_s
    end
  end
end
