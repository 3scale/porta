# REFACTOR: extract to separate TrialPeriod class. https://www.pivotaltracker.com/story/show/6779593
#
module Contract::Trial
  extend ActiveSupport::Concern

  included do
    before_create :set_trial_period_expires_at, :set_setup_fee

    attr_protected :trial_period_expires_at

    sifter :trial_period_expires_on do |date|
      sift(:date, trial_period_expires_at) == sift(:date, quoted(date.to_date))
    end

    scope :with_trial_period_expiring_in_days_since, ->(days,now) do
      with_trial_period_expired(now + days.days)
    end

    scope :with_trial_period_expired, ->(date = Time.zone.now) do
      where.has do
        sift(:trial_period_expires_on, date)
      end
    end

    scope :with_trial_period_expired_or_accepted, ->(date = Time.zone.now) do
      where.has do
        sift(:trial_period_expires_on, date) | (accepted_at.not_eq(nil) & paid_until.eq(nil))
      end
    end
  end

  module ClassMethods
    # REFACTOR: extract to notifier
    def notify_about_expired_trial_periods(now = Time.now.utc)
      trials = 0

      increment = ->(&block) { block.call; trials = trials.next }

      with_trial_period_expiring_in_days_since(10,now).find_each do |cinstance|
        increment.call(&cinstance.method(:notify_about_expired_trial_period))
      end

      with_trial_period_expired(Date.today).find_each do |cinstance|
        increment.call(&cinstance.method(:notify_provider_trial_expired_today))
      end

      trials
    end
  end

  def trial?(now = Time.now)
    # TODO: - can remove the non-nil condition when cinstance for
    # master has trial_period_expires_at set on factory creation (in tests)
    trial_period_expires_at && (now.utc < trial_period_expires_at.utc)
  end

  def remaining_trial_period_days
   (remaining_trial_period_seconds / 1.day).round
  end

  def remaining_trial_period_seconds
    [trial_period_expires_at - Time.now.utc, 0].max
  end

  # REFACTOR: extract to notifier
  def notify_about_expired_trial_period
    if paid_and_trial? && !provider_account.provider_can_use?(:new_notification_system)
      messenger.expired_trial_period_notification(self).deliver
    end
  end

  def notify_provider_trial_expired_today
    notify_observers(:expired_trial_period) if paid_and_trial?
  end

  def set_trial_period_expires_at
    self.trial_period_expires_at = Time.now.utc + (plan.trial_period_days || 0).days
  end

  def set_setup_fee
    self.setup_fee = (plan.setup_fee || 0)
  end

  private

  def paid_and_trial?
    plan.paid? && plan.trial_period_days && !plan.trial_period_days.zero?
  rescue NoMethodError => exception
    System::ErrorReporting.report_error(exception, cinstance_id: id)
    false
  end
end
