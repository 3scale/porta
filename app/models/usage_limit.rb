class UsageLimit < ApplicationRecord
  attr_accessible :period, :value, :metric, :plan

  include Backend::ModelExtensions::UsageLimit

  # These are all possible values that can be assigned to :period attribute.
  PERIODS = ThreeScale::Core::UsageLimit::PERIODS

  audited

  belongs_to :plan, :polymorphic => true
  belongs_to :metric

  # This association can be used only when joined. See Plan.usage_limits#visible
  # It creates complex condition to join association correctly,
  # before the join was: LEFT OUTER JOIN `plan_metrics` ON `plan_metrics`.`metric_id` = `usage_limits`.`metric_id`
  # now is: AND ((`plan_metrics`.`plan_id` = `usage_limits`.`plan_id` AND `plan_metrics`.`plan_type` = `usage_limits`.`plan_type`))
  # That ensures 1:1 mapping between usage limits and plan metrics. Before it was
  # joining ALL plan metrics and filtering them in WHERE, which is wrong.
  has_many :plan_metrics, -> {
    usage_limits = BabySqueel[:usage_limits]
    where.has { plan_id.eq(usage_limits.plan_id) & plan_type.eq(usage_limits.plan_type) }
  }, primary_key: :metric_id, foreign_key: :metric_id

  symbolize :period

  validates :period, inclusion: { :in => PERIODS, :message => 'is invalid' }
  validates :metric, presence: true #, :plan #plan.customize method hinders this validation
  validates :plan, presence: true

  validates :period, uniqueness: {scope: [:metric_id, :plan_id]}

  before_save :set_value_default_value

  delegate :service, :to => :plan, :allow_nil => true

  scope :of_plan, ->(plan) { where(:plan_id => plan.to_param) }
  scope :of_metric, ->(metric) { where(:metric_id => metric.to_param) }
  scope :zero, -> { where(value: 0) }

  def period_as_range(from = Time.zone.now)
    self.class.period_range(period, from)
  end

  def self.period_length(period)
    1.send(period.to_sym)
  end

  # Current running period as range
  def self.period_range(period, from = Time.zone.now)
    case period
    when :second then from..(from + 1.second)
    when :minute then from.change(:sec => 0)..from.change(:sec => 59)
    when :hour then from.change(:min => 0)..from.change(:min => 59, :sec => 59)
    when :eternity then from.change(:year => 1970, :month => 1, :day => 1, :hour => 00, :min => 00, :sec => 00)..from.change(:year => 9999, :month => 12, :day => 31, :hour => 23, :min => 59, :sec => 59)
    else from.send("beginning_of_#{period}")..from.send("end_of_#{period}")
    end
  end

  def to_xml(options = {})
    xml = options[:builder] || ThreeScale::XML::Builder.new

    xml.limit do |xml|
      xml.id_         id unless new_record?
      xml.metric_id  self.metric_id
      xml.plan_id    self.plan_id
      xml.period     self.period
      xml.value      value
    end

    xml.to_xml
  end

  def provider_id_for_audits
    metric.service.account.try!(:id)
  end

  private

  def set_value_default_value
    self.value = 0 if (self.value.blank? || self.value < 0)
  end
end
