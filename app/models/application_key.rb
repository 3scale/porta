class ApplicationKey < ApplicationRecord

  KEYS_LIMIT = 5

  APP_KEY_FORMAT = /[a-z\d][a-z\d\-\_]*[a-z\d]/i.freeze


  belongs_to :application, :class_name => 'Cinstance', :inverse_of => :application_keys

  attr_accessible :application, :value

  validates :application, presence: true
  # letters, numbers, dash, cannot stat with dash, case insensitive
  validates :value, format: { with: /\A#{APP_KEY_FORMAT}\Z/ },
                    length: { within: 5..255 },
                    uniqueness: { scope: :application_id }

  validate :keys_limit_reached

  after_save :publish_application_event

  after_commit :push_webhook_key_created, :on => :create
  after_commit :push_webhook_key_destroyed, :on => :destroy

  after_commit :notify_after_create, :on => :create, :if => :should_notify?
  after_commit :notify_after_destroy, :on => :destroy, :if => :should_notify?

  delegate :account, to: :application, allow_nil: true

  attr_readonly :value

  extend BackendClient::ToggleBackend

  module AssociationExtension
    include ReferrerFilter::AssociationExtension
    include System::AssociationExtension

    def add(value = nil)
      super(value || ApplicationKey.generate)
    end

    def remove(value)
      can_remove?(value) && super
    end

    def remove!(value)
      transaction do
        record = find_by_value!(value)
        delete(record)
      end
    end

    # just > because in that point of time record is in the association
    def limit_reached?
      size > keys_limit
    end

    def can_add?
      size < keys_limit
    end

    def can_remove?(value)
      not proxy_association.owner.service.mandatory_app_key && without(value).empty?
    end

    # Only oauth applicatinons can regenerate keys
    def regenerate(value)
      succeeded = false
      renegerate_transaction = transaction do
        remove!(value)
        succeeded = add()
        proxy_association.owner.touch if succeeded
        succeeded
      end

      push_webhook_key_updated() if succeeded
      renegerate_transaction
    end

    private

    def keys_limit
      proxy_association.owner.keys_limit
    end

    def push_webhook_key_updated
      application = proxy_association.owner
      application.push_web_hooks_later(event: "key_updated")
    end

  end

  def should_notify?
    NotificationCenter.new(self).enabled?
  end

  def to_param
    value or super
  end

  alias to_s to_param

  def to_xml(options = {})
    builder = options[:builder] || ThreeScale::XML::Builder.new
    root = options[:root] || 'key'
    builder.tag!(root) do |xml|
      xml.value value

      unless new_record?
        xml.updated_at updated_at
        xml.created_at created_at
      end
    end

    builder.to_xml
  end

  def update_backend_value
    ThreeScale::Core::ApplicationKey.save(application.service.backend_id,
                                          application.application_id,
                                          value)
  end

  def destroy_backend_value
    ThreeScale::Core::ApplicationKey.delete(application.service.backend_id,
                                            application.application_id,
                                            value)
  end

  protected

  def publish_application_event
    Applications::ApplicationUpdatedEvent.create_and_publish!(application)
  end

  def keys_limit_reached
    keys = application.try!(:application_keys)

    if keys && keys.limit_reached?
      errors.add(:base, :limit_reached)
    end
  end

  def notify_after_create
    CinstanceMessenger.key_created(application, value).deliver
  end

  def notify_after_destroy
    CinstanceMessenger.key_deleted(application, value).deliver unless application.destroyed?
  end

  def push_webhook_key_created
    application.push_web_hooks_later(:event => "key_created")
  end

  def push_webhook_key_destroyed
    application.push_web_hooks_later(:event => "key_deleted")
  end

  # same as in backend
  def self.generate
    SecureRandom.hex(16)
  end

  def self.without(value)
    where(["#{table_name}.value <> ?", value])
  end
end
