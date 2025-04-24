class Notification < ApplicationRecord
  belongs_to :user, inverse_of: :notifications
  # This is not using the .id column, but rather using the event_id (uuid) for consistency
  belongs_to :event, class_name: EventStore::Repository.adapter.name, primary_key: :event_id

  class_attribute :available_notifications, instance_writer: false

  self.available_notifications = NotificationMailer.available_notifications.map(&:to_s).freeze

  delegate :hidden_onprem_multitenancy, to: NotificationMailer
  delegate :account, to: :user

  validates :user, :event_id, :state, :system_name, presence: true

  validates :state, length: { maximum: 20 }
  validates :title, length: { maximum: 1000 }
  validates :system_name, length: { maximum: 1000 },
                          inclusion: { in: available_notifications }

  attr_readonly :event_id, :user_id, :system_name

  state_machine :state, initial: :created do
    state :delivered

    event :deliver do
      transition created: :delivered
    end

    before_transition to: :delivered do |notification|
      notification.deliver_email_notification!
    end
  end

  def parent_event
    EventStore::Repository.find_event(parent_event_id)
  end

  def should_deliver?
    enabled? && subscribed? && permitted?
  end

  def deliver_email_notification!
    mail = NotificationDeliveryService.call(self)
    self.title ||= mail.try!(:subject)
    mail
  end

  private

  def parent_event_id
    event.try(:data).try(:[], :parent_event_id)
  end

  def subscribed?
    user.notification_preferences.include?(system_name)
  end

  def enabled?
    new_notification_system? && not_hidden_if_onprem_multitenancy?
  end

  def new_notification_system?
    user.account.provider_can_use?(:new_notification_system)
  end

  def not_hidden_if_onprem_multitenancy?
    return true unless account.master_on_premises?

    hidden_onprem_multitenancy.exclude?(system_name.to_sym)
  end

  def permitted?
    Ability.new(user).can?(:show, parent_event)
  end
end
