class NotificationPreferences < ApplicationRecord
  belongs_to :user, inverse_of: :notification_preferences

  validates :user, presence: true
  serialize :preferences, JSON

  after_initialize :set_defaults

  def self.preferences_to_hash(list, value:)
    list.reject(&:empty?).map { |method| [method.to_sym, value] }.to_h
  end

  class_attribute :disabled_by_default, :enabled_by_default,
                  :default_preferences, :available_notifications,
                  :hidden_notifications, instance_writer: false

  self.available_notifications = NotificationMailer.available_notifications.freeze

  self.disabled_by_default  = %i(post_created weekly_report daily_report).freeze
  self.enabled_by_default   = (available_notifications - disabled_by_default).freeze
  self.hidden_notifications = NotificationMailer.hidden_notifications.freeze

  enabled = preferences_to_hash(enabled_by_default, value: true)
  disabled = preferences_to_hash(disabled_by_default, value: false)

  self.default_preferences = enabled.merge(disabled).freeze

  def preferences=(preferences)
    super Hash(preferences).stringify_keys
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
end
