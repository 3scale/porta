# we want to audit created_at field
module Audited

  @ignored_attributes= %w(lock_version updated_at created_on updated_on)
end

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

    def self.delete_old
      where('created_at < ?', TTL.ago).delete_all
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

  def create_or_update
    if synchronous
      super
    elsif !enqueued
      sweeper.before_create(self)
      run_after_commit(:enqueue_job)
      self.enqueued = true
    end
  end

  def enqueue_job
    AuditedWorker.perform_async(attributes)
  end

  def sweeper
    Audited::Sweeper.instance
  end
end

Audited.audit_class.name.constantize.class_eval do
  include AuditHacks
end

module AuditedHacks

  def self.included klass
    klass.extend ClassMethods
  end

  module ClassMethods

    def audited options = {}
      super

      self.disable_auditing if Rails.env.test?

      include InstanceMethods
    end

    def synchronous
      original = Thread.current[:audit_hacks_synchronous]

      Thread.current[:audit_hacks_synchronous] = true

      yield if block_given?

      original
    ensure
      Thread.current[:audit_hacks_synchronous] = original
    end

    def with_auditing
      original_state = auditing_enabled
      enable_auditing

      synchronous {  yield }
    ensure
      self.auditing_enabled = original_state
    end
  end

  module InstanceMethods

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

::ActiveRecord::Base.send :include, AuditedHacks

# This fixes issues with overloading current_user in our controllers
Audited::Sweeper.prepend(Module.new do
                           def current_user
                             User.current
                           end
                         end)
