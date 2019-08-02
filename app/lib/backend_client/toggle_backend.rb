require 'set'

module BackendClient
  module ToggleBackend
    @@bases = Set.new

    def self.disable_all!
      each(&:disable_backend!)
    end

    def self.enable_all!
      each(&:enable_backend!)
    end

    def self.without_backend(&block)
      states = {}

      each do |base|
        states[base] = base.backend_enabled?
        base.disable_backend!
      end

      yield
    ensure
      states.each do |base, state|
        base.enable_backend! if state
      end
    end

    def self.each(&block)
      @@bases.each do |base|
        yield base.constantize
      end
    end

    def self.extended(base)
      @@bases << base.to_s

      base.instance_eval do
        class_attribute :backend_enabled, :instance_reader => false, :instance_writer => false

        after_commit :update_backend_value, :on => :create, :if => proc { base.backend_enabled? }

        after_destroy { ThreeScale::AfterCommitOnDestroy.enqueue(method(:destroy_backend_value)) if base.backend_enabled? }
        after_commit { ThreeScale::AfterCommitOnDestroy.run! }
        after_rollback { ThreeScale::AfterCommitOnDestroy.clear! }
      end

      base.enable_backend!
    end

    def backend_enabled?
      !!self.backend_enabled
    end

    def turn_backend(state)
      self.backend_enabled = state
    end

    def enable_backend!
      turn_backend(true)
      Rails.logger.debug "Enabled backend interaction for #{self}"
    end

    def disable_backend!
      turn_backend(false)
      Rails.logger.debug "Disabled backend interaction for #{self}"
    end

    def without_backend(&block)
      enabled = backend_enabled?
      disable_backend! if enabled
      yield
    ensure
      enable_backend! if enabled
    end
  end
end
