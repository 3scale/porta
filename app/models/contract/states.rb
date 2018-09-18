module Contract::States
  extend ActiveSupport::Concern

  included do
    include AfterCommitQueue

    state_machine :initial => :pending do

      around_transition do |contract, _transition, block|
        previously_enabled = contract.enabled?
        block.call
        contract.publish_enabled_changed_event if contract.persisted? && contract.enabled? != previously_enabled
      end

      state :pending

      state :live
      state :suspended
      state :deprecated

      after_transition :to => :suspended, :do => :suspend_after_commit
      before_transition to: :live, do: :update_accepted_at
      after_transition :to => :live, :do => :accept_after_commit
      # there is no schedule_for_destroy
      # after_transition :to => :deprecated, :do => :schedule_for_destroy

      event :accept do
        transition :pending => :live
      end

      event :suspend do
        transition :live => :suspended
      end

      event :resume do
        transition :suspended => :live
      end

      event :deprecate do
        transition :live => :deprecated
      end
    end

    def enabled?
      live? && buyer_account.enabled?
    end
  end

  module ClassMethods
    def allowed_states
      state_machine.states.keys - [:deprecated]
    end

    def by_state(state)
      if state.present?
        where(state: state.to_s)
      else
        where({})
      end
    end
  end

  def publish_enabled_changed_event
    Applications::ApplicationEnabledChangedEvent.create_and_publish!(self)
  end

  def suspend_after_commit
    if self.is_a?(Cinstance)
      @webhook_event = 'suspended'
    end
    run_after_commit(:suspend_callbacks)
  end

  def update_accepted_at
    return if accepted_on_create
    self.accepted_at = Time.zone.now
  end

  def accept_after_commit
    run_after_commit do
      notify_observers(:accepted)
    end
  end

  def suspend_callbacks
    messenger.suspended(self).deliver
  end
end
