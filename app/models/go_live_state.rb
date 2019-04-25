class GoLiveState < ApplicationRecord

  belongs_to :account
  serialize :steps, OpenStruct
  alias_attribute :closed, :finished

  validates :recent, length: {maximum: 255}

  def advance(step, final_step=false)
    unless self.closed?
      step = step.to_s

      self.steps[step] = true
      self.recent = step
      save
    end

    GoLiveNotification.notice(self.account).deliver_now if final_step
  end

  def can_advance_to?(step)
    !closed && !steps[step]
  end

  def poll?
    !closed && recent.to_s == 'verify_api_sandbox_traffic'
  end

  def close!
    self.closed = true
    save!
  end

  def open!
    self.closed = false
    save!
  end
end
