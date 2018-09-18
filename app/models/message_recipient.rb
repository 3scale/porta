# Represents a recipient on a message.  The kind of recipient (to, cc, or bcc) is
# determined by the +kind+ attribute.
#
# == States
#
# Recipients can be in 1 of 2 states:
# * +unread+ - The message has been sent, but not yet read by the recipient.  This is the *initial* state.
# * +read+ - The message has been read by the recipient
#
# == Interacting with the message
#
# In order to perform actions on the message, such as viewing, you should always
# use the associated event action:
# * +view!+ - Marks the message as read by the recipient
#
# == Hiding messages
#
# Although you can delete a recipient, it will also delete it from everyone else's
# message, meaning that no one will know that person was ever a recipient of the
# message.  Instead, you can hide messages from users with the following actions:
# * +hide!+ -Hides the message from the recipient's inbox
# * +unhide!+ - Makes the message visible again
class MessageRecipient < ApplicationRecord
  belongs_to :message
  belongs_to :receiver, polymorphic: true

  has_one :system_operation, through: :message

  validates :message_id, :kind, :receiver_id, :receiver_type, presence: true
  validates :receiver_type, :kind, :state, length: { maximum: 255 }

  attr_protected :message_id, :receiver_id, :receiver_type, :tenant_id

  # Make this class look like the actual message
  delegate  :sender, :subject, :body, :recipients, :to, :cc, :bcc, :created_at, :sender_name,
            :to => :message

  delegate :emails, to: :receiver

  scope :visible,      -> { where(hidden_at: nil) }
  scope :latest,       -> { latest_first.limit(5) }
  scope :kind_first,   -> { order(kind: :desc).order(id: :asc) }
  scope :with_message, -> { includes(:message).references(:message) }
  scope :latest_first, -> { with_message.merge(Message.order(created_at: :desc)) }
  # I know it does not make much sense for received messages to have state sent, but it is like that
  scope :received,     -> { with_message.merge(Message.sent) }
  scope :unread,       -> { where(state: 'unread') }
  scope :not_deleted,  -> { where(deleted_at: nil) }
  scope :deleted,      -> { where.not(deleted_at: nil) }
  scope :hidden,       -> { not_deleted.where.not(hidden_at: nil) }
  scope :of_account,   ->(account) { where(receiver: account) }
  scope :not_system,   lambda {
    includes(:message).where(messages: { system_operation_id: nil }).references(:message)
  }

  state_machine :initial => :unread do

    state :unread
    state :read

    event :view do
      transition :unread => :read, :if => :message_sent?
    end
  end

  # Forwards the message
  def forward
    message = self.message.class.new(:subject => subject, :body => body)
    message.sender = receiver
    message
  end

  # Replies to the message
  def reply
    message = self.message.class.new(:subject => "Re: #{subject}",
                                     :body => body.gsub(/^/, '> '))
    message.sender = receiver
    message.to(sender)
    message
  end

  # Replies to all recipients on the message, including the original sender
  def reply_to_all
    message = reply
    message.to(to - [receiver] + [sender])
    message.cc(cc - [receiver])
    message.bcc(bcc - [receiver])
    message
  end

  # Hides the message from the recipient's inbox
  def hide!
    update_attribute(:hidden_at, Time.zone.now)
  end

  # Makes the message visible in the recipient's inbox
  def unhide!
    update_attribute(:hidden_at, nil)
  end

  # Is this message still hidden from the recipient's inbox?
  def hidden?
    hidden_at?
  end


  def self.number_of_unread_for user
    user.received_messages.where(:state => :unread).count
  end

  def notifiable?
    operation = message.system_operation

    default = case receiver
              when Account
                !Notifications::NewNotificationSystemMigration.new(receiver).enabled?
              else
                true
              end

    return default unless operation

    receiver.dispatch_rule_for(operation).dispatch?
  end

  # TODO: remove after position column is removed from the database
  class << self
    def instance_method_already_implemented?(method_name)
      return true if method_name =~ /^position/
      super
    end
  end

  private
    # Has the message this recipient is on been sent?
    def message_sent?
      message.state == 'sent'
    end

end
