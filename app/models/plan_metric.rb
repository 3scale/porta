class PlanMetric < ApplicationRecord
  belongs_to :plan, :polymorphic => true
  belongs_to :metric

  validates :plan, presence: true
  validates :metric, presence: true
end
