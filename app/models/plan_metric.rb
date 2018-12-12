class PlanMetric < ApplicationRecord
  belongs_to :plan, :polymorphic => true
  belongs_to :metric

  attr_protected :plan_id, :metric_id, :plan_type, :tenant_id

  validates :plan, presence: true
  validates :metric, presence: true

  scope :hidden, -> { where(visible: false) }

  def self.visible?(metric:, plan:)
    plan_metric = find_by(metric: metric, plan: plan) || PlanMetric.new(visible: true)
    plan_metric.visible?
  end
end
