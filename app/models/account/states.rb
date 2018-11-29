module Account::States
  PERIOD_BEFORE_DELETION = 15.days.freeze
  MAX_PERIOD_OF_SUSPENSION = 90.days.freeze
  MAX_PERIOD_OF_INACTIVITY = 1.year.freeze
  STATES = %i[created pending approved rejected suspended scheduled_for_deletion].freeze
  extend ActiveSupport::Concern

  included do
    include AfterCommitQueue

    # XXX: This state machine smells. The :created state does not feel right. I seems it would
    # be better to start in :pending state, but then it's difficult to send the confirmed emails,
    # because hooking them to after_created won't work since there is no user to send it to yet.

    state_machine :initial => :created do

      STATES.each { |state_name| state state_name }

      around_transition do |account, _transition, block|
        previous_state = account.state

        block.call

        account.publish_state_changed_event(previous_state) unless previous_state == account.state
      end

      before_transition :to => :pending do |account|
        account.deliver_confirmed_notification
      end

      before_transition :to => :approved do |account|
        account.deliver_approved_notification
      end

      before_transition :to => :rejected do |account|
        account.deliver_rejected_notification
      end

      after_transition to: :suspended do |account|
        account.run_after_commit(:notify_account_suspended)
        account.bought_account_contract&.suspend if account.provider?
      end

      after_transition any - :scheduled_for_deletion => :scheduled_for_deletion do |account|
        account.run_after_commit(:schedule_backend_sync_worker)
      end

      after_transition :scheduled_for_deletion => any - :scheduled_for_deletion do |account, _transition|
        account.run_after_commit(:schedule_backend_sync_worker)
      end

      after_transition to: :approved, from: :suspended do |account|
        account.run_after_commit(:notify_account_resumed)
        account.bought_account_contract&.resume if account.provider?
      end

      after_transition to: :approved, from: [:created, :pending] do |account|
        account.bought_account_contract&.accept
      end

      after_transition any => any do |account|
        time_state_changed_at = Time.zone.now
        account.update_attributes(state_changed_at: time_state_changed_at, deleted_at: time_state_changed_at)
      end

      event :make_pending do
        transition :created => :pending
        transition :approved => :pending
        transition :rejected => :pending
      end

      event :approve do
        transition :created => :approved
        transition :pending => :approved
        transition :rejected => :approved
      end

      event :reject do
        transition :created => :rejected
        transition :pending => :rejected
        transition :approved => :rejected
      end

      event :suspend do
        transition all => :suspended, if: :tenant?
      end

      event :resume do
        transition :suspended => :approved, if: :provider?
        transition :scheduled_for_deletion => :approved
      end

      event :schedule_for_deletion do
        transition all => :scheduled_for_deletion, unless: :master?
      end
    end

    scope :without_deleted, ->(without = true) { where.has { state != :scheduled_for_deletion } if without }

    scope :by_state, ->(state) do
      where(:state => state.to_s) if state.to_s != "all"
    end

    scope :deleted_since, ->(value = nil) do
      scheduled_for_deletion.where.has { state_changed_at <= (value || PERIOD_BEFORE_DELETION.ago) }
    end

    scope :suspended_since, ->(value = nil) do
      suspended.where.has { state_changed_at <= (value || MAX_PERIOD_OF_SUSPENSION.ago) }
    end

    scope :inactive_since, ->(value = nil) do
      inactivity_period = (value || MAX_PERIOD_OF_INACTIVITY.ago)
      where.has { created_at <= inactivity_period }.without_traffic_since(inactivity_period)
    end

    scope :without_traffic_since, ->(value = nil) do
      inactivity_period = (value || MAX_PERIOD_OF_INACTIVITY.ago)
      where.has do
        not_exists Cinstance.where.has { user_account_id == BabySqueel[:accounts].id }.active_since(inactivity_period)
      end
    end

    def deletion_date
      return if state_changed_at.blank? || !scheduled_for_deletion?
      (state_changed_at + PERIOD_BEFORE_DELETION)
    end

    def enabled?
      !scheduled_for_deletion? && (provider_account && !provider_account.scheduled_for_deletion?)
    end

    def should_be_deleted?
      scheduled_for_deletion? || suspended? || (buyer? && provider_account.try(:should_be_deleted?))
    end
  end

  module ClassMethods
    STATES.each { |state_name| define_method(state_name) { by_state(state_name) } }
  end

  def upgrade_state!
    if buyer? && approval_required?
      make_pending!
    else
      approve!
    end
  end

  def publish_state_changed_event(previous_state)
    Accounts::AccountStateChangedEvent.create_and_publish!(self, previous_state)
    PublishEnabledChangedEventForProviderApplicationsWorker.perform_later(self, previous_state)
  end

  def deliver_confirmed_notification
    if admins.present? && provider_account
      run_after_commit do
        AccountMessenger.new_signup(self).deliver_now
        AccountMailer.confirmed(self).deliver_now
      end
    end
  end

  def deliver_approved_notification
    if buyer? && approval_required?
      unless admins.empty? || admins.first.created_by_provider_signup?
        run_after_commit do
          AccountMailer.approved(self).deliver_now
        end
      end
    end
  end

  def deliver_rejected_notification
    unless admins.empty? || self.provider_account.nil?
      run_after_commit do
        AccountMailer.rejected(self).deliver_now
      end
    end
  end

  def notify_account_suspended
    ThreeScale::Analytics.track_account(self, 'Account Suspended')
    ThreeScale::Analytics.group(self)
    ReverseProviderKeyWorker.enqueue(self)
  end

  def notify_account_resumed
    ThreeScale::Analytics.track_account(self, 'Account Resumed')
    ThreeScale::Analytics.group(self)
    ReverseProviderKeyWorker.enqueue(self)
  end
end
