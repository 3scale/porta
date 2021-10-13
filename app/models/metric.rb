# TODO: parameter name was deprecated on 21.02.2014 and should be removed at one point.
class Metric < ApplicationRecord
  include Backend::ModelExtensions::Metric
  include SystemName
  include BackendApiLogic::MetricExtension

  self.background_deletion = %i[pricing_rules usage_limits plan_metrics proxy_rules]

  before_destroy :destroyable?
  before_validation :associate_to_service_of_parent, :fill_owner

  # update Service's updated_at when Metric caches for nicer cache keys
  belongs_to :service, touch: true
  belongs_to :owner, polymorphic: true, touch: true

  has_many :line_items, inverse_of: :metric
  has_many :pricing_rules, :dependent => :destroy
  has_many :usage_limits, :dependent => :destroy
  has_many :plan_metrics, :dependent => :destroy

  has_many :proxy_rules, :dependent => :destroy

  audited :allow_mass_assignment => true
  has_system_name uniqueness_scope: %i[owner_type owner_id], human_name: :friendly_name

  acts_as_tree

  attr_protected :service_id, :parent_id, :tenant_id, :audit_ids
  validates :unit, presence: true, unless: :child?
  validates :friendly_name, uniqueness: {scope: %i[owner_type owner_id]}, presence: true
  validates :system_name, :unit, :friendly_name, :owner_type, length: { maximum: 255 }
  validates :owner_id, :owner_type, presence: true

  validate :only_hits_has_children

  # alias_attribute :name, :system_name


  # After add the index the results for .first changed.
  # http://api.rubyonrails.org/classes/ActiveRecord/FinderMethods.html
  #
  # Rails 3 may not order this query by the primary key and the order will
  # depend on the database implementation. In order to ensure that behavior, use User.order(:id).first instead.
  #
  default_scope -> { order(:id) }
  scope :top_level, -> { where(parent_id: nil) }
  scope :order_by_unit, -> { order('unit') }

  scope :by_provider, ->(provider) {
    where.has { ((owner_type == 'Service') & owner_id.in(provider.services.pluck(:id))) | ((owner_type == 'BackendApi') & owner_id.in(provider.backend_apis.pluck(:id))) }
  }

  # Create one of the predefined, default metrics.
  #
  # == Arguments
  #
  # +type+:: Which default metric to create. Currently only :hits are supported.
  def self.create_default!(type, attributes = {})
    metric = new(attributes.merge(:friendly_name => 'Hits', :system_name => 'hits', :unit => 'hit',
                                  :description => 'Number of API hits'))
    metric.service_id = attributes[:service_id]
    metric.save!
    metric
  end

  def self.ids_indexed_by_names
    all.index_by(&:system_name).downcase_keys.map_values(&:id)
  end

  def self.ancestors_ids
    includes([:parent]).inject({}) do |memo, metric|
      ancestors_ids = metric.ancestors.map(&:id)
      memo[metric.id] = ancestors_ids unless ancestors_ids.empty?
      memo
    end
  end

  def self.hits
    extended_system_name = self.hits_extended_system_name_as_sql
    collection = top_level.where.has { system_name.eq('hits') | system_name.eq(extended_system_name) }.presence || top_level
    collection.first
  end

  def self.hits!
    hits or raise ActiveRecord::RecordNotFound
  end

  # alias
  def name
    self.system_name
  end

  # Is this default metric of given type?
  #
  # == Arguments
  #
  # +type+:: Only :hits are supported right now.
  def default?(type)
    if type == :hits
      system_name.to_s =~ self.class.hits_extended_system_name_regex
    else
      system_name && system_name.to_sym == type.to_sym
    end
  end

  def hits?
    default?(:hits)
  end

  def child?
    parent_id.present?
  end

  def parent?
    not children.empty?
  end

  def only_hits_has_children
    return if !child? || parent.system_name =~ self.class.hits_extended_system_name_regex
    errors.add :parent_id, "You can only create methods under 'hits'"
  end

  def unit
    child? ? parent.unit : self[:unit]
  end

  def unit=(value)
    self[:unit] = value unless child?
  end

  alias method_metric? child?

  def to_xml(options = {})
    xml = options[:builder] || ThreeScale::XML::Builder.new

    metric_or_method = method_metric? ? 'method' : 'metric'

    xml.__send__(:method_missing, metric_or_method) do |xml|
      xml.id_           id unless new_record?
      xml.name          name # As of February 2014 this is deprecated and should be removed
      xml.system_name   name
      xml.friendly_name friendly_name
      xml.service_id    service_id
      xml.description   description
      if method_metric?
        xml.metric_id parent_id
      else
        xml.unit unit
      end
    end

    xml.to_xml
  end

  def toggle_visible_for_plan(plan)
    plan_metric = find_or_create_plan_metric(plan)
    plan_metric.toggle :visible
    plan_metric.save
  end

  def visible_in_plan?(plan)
    if pm = find_plan_metric(plan)
      pm.visible?
    else # default is ...
      true
    end
  end

  def toggle_limits_only_text_for_plan(plan)
    plan_metric = find_or_create_plan_metric(plan)
    plan_metric.toggle :limits_only_text
    plan_metric.save
  end

  def limits_only_text_in_plan?(plan)
    if pm = find_plan_metric(plan)
      pm.limits_only_text?
    else # default is ...
      true
    end
  end

  def toggle_enabled_for_plan(plan)
    if enabled_for_plan?(plan)
      disable_for_plan plan
    else
      enable_for_plan plan
    end
  end

  def enable_for_plan(plan)
    plan.usage_limits.where(value: 0, metric_id: self.id).destroy_all
  end

  def disable_for_plan(plan)
    used_periods   = plan.usage_limits.of_metric(self).pluck(:period).uniq.map(&:to_sym)
    unused_periods = UsageLimit::PERIODS - used_periods

    if unused_periods.present?
      plan.usage_limits
        .create(period: unused_periods.first, value: 0, metric: self)
    else
      errors.add :base, :all_periods_used
      false
    end
  end

  def enabled_for_plan?(plan)
    not plan.usage_limits.zero.of_metric(self).exists?
  end

  def disabled_for_plan?(plan)
    !enabled_for_plan?(plan)
  end

  private

  def destroyable?
    return true if destroyed_by_association
    throw :abort if system_name == 'hits'
  end

  def find_or_create_plan_metric(plan)
    plan_metric = find_plan_metric(plan)
    plan_metric ||= plan.plan_metrics.build :metric => self, :plan => plan
  end

  def find_plan_metric(plan)
    plan_metrics = plan.plan_metrics
    metric = nil

    if plan_metrics.loaded?
      metric = (@_cached_plan_metrics ||= plan_metrics.to_a)
        .find{ |plan_metric| plan_metric.metric_id == self.id }
    end
    # in case it is not cached, try db search
    metric ||= plan_metrics.find_by_metric_id(self.id)
  end

  def associate_to_service_of_parent
    self.service = parent.service if parent
  end

  protected

  delegate :provider_id_for_audits, :to => :service, :allow_nil => true

  def fill_owner
    return true if owner_type?

    if new_record? && child?
      self.owner = parent.owner
    else
      self.owner_id = service_id
      self.owner_type = 'Service'
    end
  end
end
