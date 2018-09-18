# Represents a message sent from one user to one or more others.
#
# == States
#
# Messages can be in 1 of 3 states:
# * +unsent+ - The message has not yet been sent.  This is the *initial* state.
# * +queued+ - The message has been queued for future delivery.
# * +sent+ - The message has been sent.
#
# == Interacting with the message
#
# In order to perform actions on the message, such as queueing or delivering,
# you should always use the associated event action:
# * +queue!+ - Queues the message so that you can send it in a separate process
# * +deliver!+ - Sends the message to all of the recipients
#
# == Hiding messages
#
# Although you can delete a message, it will also delete it from the inbox of
# all the message's recipients.  Instead, you can hide messages from users with
# the following actions:
# * +hide!+ -Hides the message from the sender's inbox
# * +unhide!+ - Makes the message visible again
class Message < ApplicationRecord

  DO_NOT_SEND_HEADER      = 'X-3scale-do-not-send'.freeze
  APPLY_ENGAGEMENT_FOOTER = 'X-3scale-viral'.freeze

  belongs_to :sender, class_name: 'Account'
  belongs_to :system_operation
  has_many   :recipients, -> { kind_first }, class_name: 'MessageRecipient', dependent: :destroy

  validates :sender_id, presence: true

  after_save :update_recipients
  after_initialize :default_values

  attr_protected :sender_id, :tenant_id

  scope :visible,      -> { where(hidden_at: nil) }
  scope :hidden,       -> { where.not(hidden_at: nil) }
  scope :latest_first, -> { order(created_at: :desc) }
  scope :of_account,   ->(account) { where(sender: account) }
  scope :not_system,   -> { where(system_operation_id: nil) }
  scope :not_system_for_provider, -> {
    joins(:sender).where.has do
      (system_operation_id == nil) |
        ((system_operation_id != nil) & (sender.provider == true))
    end
  }

  scope :sent, -> { where(state: 'sent') }

  state_machine :initial => :unsent do

    state :unsent
    state :queued
    state :sent

    after_transition :to => :sent do |message|
      message.send_notifications
    end

    event :queue do
      transition :unsent => :queued, :if => :has_recipients?
    end

    event :deliver do
      transition [:unsent, :queued] => :sent, :if => :has_recipients?
    end
  end

  serialize :headers

  # Directly adds the receivers on the message (i.e. they are visible to all
  # recipients)
  def to(*receivers)
    receivers(receivers, 'to')
  end
  alias to= to


  # Carbon copies the receivers on the message
  def cc(*receivers)
    receivers(receivers, 'cc')
  end
  alias cc= cc

  # Blind carbon copies the receivers on the message
  def bcc(*receivers)
    receivers(receivers, 'bcc')
  end
  alias bcc= bcc

  # Forwards this message
  def forward
    message = self.class.new(:subject => subject, :body => body)
    message.sender = sender
    message
  end

  # Replies to this message
  def reply
    message = self.class.new(:subject => "Re: #{subject}",
                             :body => body.gsub(/^/, '> '))
    message.sender = sender
    message.to(to)
    message
  end

  # Replies to all recipients on this message
  def reply_to_all
    message = reply
    message.cc(cc)
    message.bcc(bcc)
    message
  end

  # Hides the message from the sender's inbox
  def hide!
    update_attribute(:hidden_at, Time.now)
  end

  # Makes the message visible in the sender's inbox
  def unhide!
    update_attribute(:hidden_at, nil)
  end

  # Is this message still hidden from the sender's inbox?
  def hidden?
    hidden_at?
  end

  def enqueue!(receivers)
    # saved records are already "sent"
    return unless new_record?
    MessageWorker.enqueue(receivers, attributes)
  end

  def send_notifications
    # Notify recipients also by email.
    recipients.find_each do |recipient|

      if !system_operation? && recipient.receiver.try(:provider?)
        event = Messages::MessageReceivedEvent.create(self, recipient)
        Rails.application.config.event_store.publish_event(event)
      end

      if recipient.notifiable?
        report_and_supress_exceptions do
          attempt_to_send_message(recipient) if can_send_message?(recipient)
        end
      end
    end
  end

  def to_xml(options = {})
    builder = options[:builder] || ThreeScale::XML::Builder.new

    builder.message do |xml|
      xml.id_ id
      xml.body body
      xml.subject subject
      xml.state state
      # TODO: recipients
    end

    builder.to_xml
  end

  # Create/destroy any receivers that were added/removed
  def update_recipients
    if @receivers
      @receivers.each do |kind, receivers|
        kind_recipients = recipients.select {|recipient| recipient.kind == kind}
        new_receivers = receivers - kind_recipients.map(&:receiver)
        removed_recipients = kind_recipients.reject {|recipient| receivers.include?(recipient.receiver)}

        recipients.delete(*removed_recipients) if removed_recipients.any?
        new_receivers.each {|receiver| recipients.create!(:receiver => receiver, :kind => kind)}
      end

      @receivers = nil
    end
  end

  protected

  def can_send_message?(recipient)
    if recipient.emails.present?
      true
    else
      logger.warn "Skipping message notification for Message(id:#{id}) because account has no emails."
      false
    end
  end

  def attempt_to_send_message(recipient)
    PostOffice.message_notification(self, recipient).deliver_now
  rescue ArgumentError => error
    System::ErrorReporting.report_error error_class: error,
                    error_message: "Got #{error} for message_id: `#{recipient.message_id}' and recipient `#{recipient.id}' -- #{recipient.emails.inspect}"
  end

  private

  def system_operation?
    system_operation_id.present?
  end

  def default_values
    self.headers ||= {}
  end

  # Does this message have any recipients on it?
  def has_recipients?
    (to + cc + bcc).any?
  end

  # Creates new receivers or gets the current receivers for the given kind (to,
  # cc, or bcc)
  def receivers(receivers, kind)
    if receivers.any?
      (@receivers ||= {})[kind] = receivers.flatten.compact
    else
      @receivers && @receivers[kind] || recipients.select {|recipient| recipient.kind == kind}.map(&:receiver)
    end
  end

end
