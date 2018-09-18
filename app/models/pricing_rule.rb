class PricingRule < ApplicationRecord
  DECIMALS = 4
  audited :allow_mass_assignment => true

  belongs_to :plan
  belongs_to :metric

  attr_protected :metric_id, :plan_id, :plan_type, :tenant_id, :audit_ids

  # TODO: add validations that check that the intervals are well defined. TODO:
  # min must be always > 0
  #
  # TODO: first pricing rule must have min == 1
  #
  # TODO: every other rule must have min == (greatest max of previous rules) + 1
  validate :range_overlap

  validates :min, numericality: { :only_integer => true,
    :greater_than_or_equal_to => 1 }

  validates :cost_per_unit, numericality: true
  validates :cost_per_unit, format: { with: /\A\d+\.?\d{0,#{DECIMALS}}\z/, message: "maximum decimals is #{DECIMALS}." }

  scope :for_metric, lambda { |metric| where(:metric_id => metric.to_param) }

  delegate :service, :to => :plan

  def self.columns
    super.reject { |c| c.name == 'plan_type'.freeze }
  end

  # What's the cost of usage when rules from this collection are applied.
  def self.cost_for_value(value)
    all.to_a.sum { |rule| rule.cost_for_value(value) }
  end

  # What's the cost of usage when only this rule is applied.
  def cost_for_value(value)
    if value < min
      0
    elsif value == max && value == min
      cost_per_unit
    elsif max.nil? || value <= max
      cost_per_unit * (value - min + 1)
    else
      cost_per_unit * (max - min + 1)
    end
  end

  def cost_per_unit_as_money
    (cost_per_unit || 0).to_has_money(plan.currency)
  end

  def to_xml(options = {})
    xml = options[:builder] || ThreeScale::XML::Builder.new

    xml.pricing_rule do |xml|
      xml.id_ id
      xml.metric_id metric_id
      xml.plan_id plan_id
      xml.cost_per_unit cost_per_unit
      xml.min min
      xml.max max
    end

    xml.to_xml
  end

  private

  def range_overlap
    return if min.nil?

    rules = PricingRule.where({:plan_id => plan_id, :metric_id => metric_id})

    infinity = 1.0 / 0 # a nil max value represents infinity

    overlap = false
    rules.each do |rule|
        # Ranges version of (min <= (rule.max || infinity) && (max || infinity) >= rule.min)
        overlap = (rule.min..(rule.max||infinity)).overlaps? min..(max||infinity)

        if !new_record? && id == rule.id
          overlap = false
        end

        break if overlap
    end

    if overlap #rules.count > 0
      errors.add(:min, "'From' value cannot be less than 'To' values of current rules.")
    end

    if max && max < min
      errors.add(:max, "'To' value cannot be less than your 'From' value.")
    end
  end
end
