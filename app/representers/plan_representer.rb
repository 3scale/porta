module PlanRepresenter
  extend ActiveSupport::Concern

  included do
    property :id
    property :name

    property :state
    property :setup_fee
    property :cost_per_month
    property :trial_period_days
    property :cancellation_period

    property :default

    property :created_at
    property :updated_at
  end

  def setup_fee
    super.to_f
  end

  def cost_per_month
    super.to_f
  end

  def trial_period_days
    super.to_i
  end

  def default
    master?
  end

end
