module AuditHacks
  extend ActiveSupport::Concern

  TTL = 3.months

  included do
    include AfterCommitQueue

    attr_accessor :enqueued
    attr_writer :synchronous

    # this could also validate provider_id, but unfortunately we have to much going on
    # and factories destroy the whole thing
    validates :kind, :presence => true

    alias_attribute :association_id, :associated_id
    alias_attribute :association_type, :associated_type

    after_commit :log_to_stdout, on: :create, if: :logging_to_stdout?

    def self.delete_old
      where('created_at < ?', TTL.ago).delete_all
    end

    def self.logging_to_stdout?
      Features::LoggingConfig.config.audits_to_stdout
    end

    delegate :logging_to_stdout?, to: :class

    def log_to_stdout
      logger.tagged('audit', kind, action) { logger.info log_trail }
    end

    def obfuscated
      dup.tap do |copy|
        copy.send(:write_attribute, :id, id)
        copy.send(:write_attribute, :created_at, created_at)
        copy.audited_changes = ThreeScale::FilterArguments.new(audited_changes).filter if audited_changes
      end
    end

    protected

    def log_trail
      to_h_safe.to_json
    end

    alias_method :to_s, :log_trail

    def to_h_safe
      attrs = %w[auditable_type auditable_id action audited_changes version provider_id user_id user_type request_uuid remote_address created_at]
      hash = obfuscated.attributes.slice(*attrs)
      hash['user_role'] = user&.role
      hash['audit_id'] = id
      hash
    end
  end

  def audited_changes_for_destroy_list
    changes = audited_changes.extract!(*kind.constantize.attributes_for_destroy_list)
    changes.merge('id' => auditable_id)
  end

  def synchronous
    self.class.synchronous || @synchronous
  end

  def persisted?
    synchronous ? super : true
  end

  def create_or_update(*args)
    Audited.audit_class.as_user(User.current) do
      if synchronous
        super
      elsif !enqueued
        # all before_create callbacks except version
        set_audit_user
        set_request_uuid
        set_remote_address

        run_after_commit(:enqueue_job)
        self.enqueued = true
      end
    end
  end

  def enqueue_job
    AuditedWorker.perform_async(attributes)
  end

end

module AuditedHacks
  extend ActiveSupport::Concern

  included do
    extend ClassMethods
  end

  module ClassMethods
    def audited(options = {})
      super

      self.disable_auditing if Rails.env.test?

      include InstanceMethods
      class << self
        prepend ClassMethods
      end
    end

    def synchronous
      original = Thread.current.thread_variable_get(:audit_hacks_synchronous)

      Thread.current.thread_variable_set(:audit_hacks_synchronous, true)
      yield if block_given?

      original
    ensure
      Thread.current.thread_variable_set(:audit_hacks_synchronous, original)
    end

    def with_synchronous_auditing(&block)
      synchronous { with_auditing(&block) }
    end
  end

  module InstanceMethods
    def auditing_enabled?
      auditing_enabled
    end

    private

    def write_audit(attrs)
      if auditing_enabled
        provider_id = respond_to?(:tenant_id) && self.tenant_id
        provider_id ||= respond_to?(:provider_account_id) && self.provider_account_id
        provider_id ||= respond_to?(:provider_id) && self.provider_id
        provider_id ||= respond_to?(:provider_account) && self.provider_account.try!(:id)
        provider_id ||= self.provider_id_for_audits

        attrs[:provider_id] = provider_id
        attrs[:kind] = self.class.to_s
      end

      super
    end

    protected
    # Overwrite this in your auditable models to return something for audit's provider_id
    #
    # for example:
    #   class Mojo < ActiveRecord::Base
    #     auditable
    #
    #     def provider_id_for_audits
    #       42
    #     end
    #   end
    def provider_id_for_audits
      nil
    end
  end
end

ActiveSupport.on_load(:active_record) do
  # we want to audit created_at field
  Audited.ignored_attributes = %w(lock_version updated_at created_on updated_on)

  Audited.audit_class.class_eval do
    include AuditHacks
  end

  # This fixes issues with overloading current_user in our controllers
  Audited::Sweeper.prepend(Module.new do
    def current_user
      User.current
    end
  end)

  ::ActiveRecord::Base.class_eval do
    include AuditedHacks
  end
end
