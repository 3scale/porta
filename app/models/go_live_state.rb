class GoLiveState < ApplicationRecord

  belongs_to :account, inverse_of: :go_live_state
  serialize :steps, type: OpenStruct
  alias_attribute :closed, :finished

  validates :recent, length: {maximum: 255}

  def advance(step, final_step=false)
    return if self.closed?

    step = step.to_s

    self.steps[step] = true
    self.recent = step
    save
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
