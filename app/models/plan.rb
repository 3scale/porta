
class Plan < ApplicationRecord
  include Searchable
  class PeriodRangeCalculationError < StandardError; end
  include Symbolize

  self.allowed_sort_columns = %w[position name state contracts_count]
  self.default_sort_column = :position
  self.default_sort_direction = :asc


  include SystemName
  include Logic::MetricVisibility::Plan

  self.background_deletion = [:cinstances, :contracts, :plan_metrics, :pricing_rules,
                              :usage_limits, [:customizations, { action: :destroy, class_name: 'Plan' }]]

  has_system_name :uniqueness_scope => [ :type, :issuer_id, :issuer_type ]

  audited :allow_mass_assignment => true
  acts_as_list scope: %i[issuer_id issuer_type]

  # There is a race condition here, the record gets deleted but the callbacks were not triggered yet
  # So we need to verify their existence before:
  #  - `#lock!` triggered by acts_as_list
  #  - `#audit_destroy` triggered by audit_destroy
  # I think those gems are fine with their behaviour.
  # The problem is on our side with so many inter-dependent relationships
  # skip_callback :destroy, :before, :lock!, if: -> { !self.class.exists?(id) || destroyed_by_association }
  skip_callback :destroy, :before, :audit_destroy, if: -> { !self.class.exists?(id) }

  validates :state, inclusion: { in: %w(hidden published) }
  before_validation(:on => :create) { set_state_to_hidden_if_nil } # otherwise the validation above fails as state machine hasnt kicked in yet (ugly)

  attr_protected :issuer_id, :original_id, :type, :issuer_type, :tenant_id, :audit_ids, :state

  state_machine :initial => :hidden do
    state :hidden
    state :published

    event :publish do
      transition :hidden => :published
    end

    event :hide do
      transition :published => :hidden
    end
  end

  symbolize :cost_aggregation_rule

  alias_attribute :backend_id, :id

  validates :cost_aggregation_rule,
                         inclusion: { :in => [:sum, :max, :min],
                         :message => 'is invalid' }

  validates :name, presence: true

  validates :setup_fee, :cost_per_month, numericality: { allow_nil: false, allow_blank: false, greater_than_or_equal_to: 0.00 }
  validates :trial_period_days, numericality: { allow_nil: true, greater_than_or_equal_to: 0 }
  validates :system_name, length: { maximum: 255 }
  validates :name, :rights, :state, :cost_aggregation_rule, :type, :issuer_type,
            length: { maximum: 255 }
  validates :full_legal, length: { maximum: 4294967295 }
  validates :description, length: { maximum: 65535 }

  # This association is redefined in child classes to take advantage of :inverse_of
  belongs_to :issuer, :polymorphic => true

  # Use `:prepend => true` so it is called before any other callback.
  # Especially there is a bug with *acts_as_list* that will call `#lock!` on the record before destroy
  # But calling `#lock!` will call `#reload` so some instance variables are reset
  before_destroy :can_be_destroyed?, prepend: true

  has_many :cinstances, :dependent => :destroy

  has_many :contracts, dependent: :destroy

  # TODO: move this to application plan, but beware
  # there is lot of code relying on these two methods on every plan
  has_many :usage_limits, as: :plan, dependent: :destroy do
    def visible
      where{ plan_metrics.visible.eq(true) | plan_metrics.plan_id.eq(nil) }
      .joins{ plan_metrics.outer }.references(:all)
    end

    include Logic::MetricVisibility::OfMetricAssociationProxy
  end

  has_many :pricing_rules, dependent: :destroy, &Logic::MetricVisibility::OfMetricAssociationProxy

  with_options(as: :plan, dependent: :destroy) do |plan|
    # having plan_metrics only in ApplicationPlan breaks eager loading, investigate after rails3
    plan.has_many :plan_metrics, foreign_key: :plan_id, &Logic::MetricVisibility::OfMetricAssociationProxy
  end

  has_many :features_plans, :as => :plan

  # FIXME: this should be a simple HABTM
  # No it can't, because it is POLYMORPHIC
  has_many :features, :through => :features_plans do
    # returns all features owned by issuer, not only enabled by plan
    def of_service
      owner = proxy_association.owner
      owner.issuer.features.with_object_scope(owner)
    end
  end

  has_many :customizations, :foreign_key => :original_id, :class_name => "Plan", :dependent => :destroy

  belongs_to :original, :class_name => self.name

  default_scope -> { order(:position) }

  scope :latest, -> { limit(5).order(created_at: :desc) }

  scope :by_state, ->(state) {  where({:state => state.to_s})}

  scope :by_type, ->(type) { where({ :type => type.to_s })}

  # Customzied plans
  scope :customized, -> { where("#{table_name}.original_id <> 0") }

  # TODO: DRY this - we only use one of those
  # Stock (not customized) plans.
  scope :stock, -> { where(original_id: [0, nil]) }
  scope :not_custom, -> { where(original_id: 0)}

  scope :alphabetically, -> { order(name: :asc) }

  def self.provided_by(account)
    where.has do
      id.in(Plan.issued_by(account).select(:id)) |
        id.in(Plan.issued_by(Service, account.service_ids).select(:id))
    end
  end

  def self.issued_by(issuer, *ids)
    case
    when (issuer == :all || issuer.blank?) && ids.blank?
      where({})
    when issuer.respond_to?(:to_model) && ids.blank?
      issued_by_type(issuer.class, issuer.id)
    else
      issued_by_type(issuer, *ids)
    end
  end

  def self.issued_by_type(issuer_type, *ids)
    where(:issuer_type => issuer_type.model_name.to_s, :issuer_id => ids.flatten)
  end

  # WARNING: same logic is present in the #free? method - if you change one, change also the other
  scope :paid, -> { where(["#{quoted_table_name}.cost_per_month != 0 OR #{quoted_table_name}.setup_fee != 0 OR pricing_rules.id IS NOT NULL"]).includes([:pricing_rules])}
  scope :free, -> { where(["#{quoted_table_name}.cost_per_month = 0 AND #{quoted_table_name}.setup_fee = 0 AND pricing_rules.id IS NULL"]).includes([:pricing_rules])}

  class << self

    def published
      by_state(:published)
    end

    def hidden
      by_state(:hidden).order(created_at: :desc)
    end

    alias by_issuer issued_by


    # Reorder plans according to list of ids.
    #
    # == Example
    #
    # Plan.reorder!([3, 2, 1]) # will reorder plans so the one with
    # id=3 will be first, the one with id=2 second and the one with id=1
    # last.
    #
    # TODO: should be a method on issuer
    #
    def reorder!(account, ids)
      ids.each_with_index do |id, position|
        account.service.application_plans.find_by_id(id).update_attribute(:position, position)
      end
    end

  end

  def reset_contracts_counter
    update_column(:contracts_count, contracts.count) if persisted?
  end
  alias reset_counter_cache reset_contracts_counter


  def can_be_destroyed?
    return true if destroyed_by_association

    # checking if customizations have contracts is a bit too much, since
    # contract.change_plan! removes customizations, but is better to be sure
    if contracts.exists?
      errors.add :base, :has_contracts
    elsif customizations.any? { |c| c.contracts.exists? }
      errors.add :base, :customizations_has_contracts
    end

    throws :abort unless errors.empty?
  end

  def cost_per_month
    money_in_currency self[:cost_per_month]
  end

  def setup_fee
    money_in_currency self[:setup_fee]
  end

  # Returns `provider_id`. See AccountPlan#currency_cache_key
  #
  def currency_cache_key
    provider_account.try!(:id) if respond_to?(:provider_account)
  end

  def currency
    if key = currency_cache_key
      Finance::BillingStrategy.account_currency(key)
    else
      Finance::BillingStrategy::CURRENCIES.values.first
    end
  end

  # Is this plan provided by given account?
  delegate :provided_by?, to: :service

  # Is there a contract used by given account?
  def bought_by?(account)
    account && contracts.bought_by(account).present?
  end

  # Set cancellation period in days.
  def cancellation_period_in_days=(days)
    self[:cancellation_period] = days.to_i.days
  end

  # Get cancellation period as number of days. This is just to make form
  # fields more user friendly.
  def cancellation_period_in_days
    self[:cancellation_period] / 1.day
  end

  def customize(attrs = {})
    custom = copy(name: attrs[:name] || "#{name} (custom)",
                  system_name: attrs[:system_name] || "#{system_name}_custom_#{randomized}",
                  original: self, state: 'hidden')

    without_auditing_for_associations { custom.save }

    custom
  end

  def without_auditing_for_associations
    ::UsageLimit.disable_auditing
    ::PricingRule.disable_auditing
    yield
  ensure
    ::PricingRule.enable_auditing
    ::UsageLimit.enable_auditing
  end

  # TODO: web_hook_failures use the same 'random' generator, dry it
  def randomized
    Time.now.utc.to_f.to_s.sub('.', '') # I know.. very RANDOM
  end

  def copy(attrs = {})
    custom = dup
    custom.name = attrs[:name] || "#{custom.name} (copy)"
    custom.system_name = attrs[:system_name] || generate_copy_system_name
    custom.position = nil
    custom.contracts_count = custom.contracts.count

    # FIXME: there is bug in acts_as_state_machine
    # aasm sets state in on create, even if it is already set
    # so next line has no effect and cloned plan will be 'hidden'
    # TODO: lets use some decent solution like state_machine gem
    custom.state = attrs[:state] || state
    custom.original = attrs[:original] unless attrs[:original].nil?
    clone_associations(custom)
    custom
  end

  def customized?
    !original.nil?
  end

  def original_name
    customized? ? original.name : name
  end

  # Aggregate costs according to aggregation rule.
  #
  # Note that for any aggregation function +f+, this must hold:
  #
  #   f(x1, x2, ..., xn) + f(y1, y2, ..., yn) = f(x1 + y1, x2 + y2, ..., xn + yn)
  #
  # Because the costs are updated incrementally (on each hit).
  def aggregate_costs(costs)
    money_in_currency costs.send(cost_aggregation_rule)
  end

  # WARNING: same logic is also present in 'free/paid' scopes; update
  # both in case of change
  #
  def free?
    self[:cost_per_month].zero? && self[:setup_fee].zero? && pricing_rules.empty?
  end

  def paid?
    !free?
  end

  delegate :trial?, :best_plan?, to: :plan_rule, allow_nil: true

  def reload(*)
    @cached_features = nil
    super
  end

  def includes_feature?(feature)
    @cached_features ||= Set.new(features.loaded? ? feature_ids : features.pluck(:id))
    @cached_features.include?(feature.id)
  end

  # Fixed cost for given period, which can be less than one month.
  def cost_for_period(period)
    return money_in_currency(0) if (cost_per_month || 0).zero?

    same_month_period = (period.begin.month == period.end.month) && (period.begin.year == period.end.year)
    raise PeriodRangeCalculationError, 'Beginning and end of the period must both be in the same month' unless same_month_period

    # our ranges are actually correct but for arithmetic purposes we do want the + 1 (length of the range/month)
    month_part = (BigDecimal((period.end.to_i + 1).to_s) - BigDecimal(period.begin.to_i.to_s)) /
                 (BigDecimal((period.begin.end_of_month.to_i + 1).to_s) - BigDecimal(period.begin.beginning_of_month.to_i.to_s))

    (cost_per_month * month_part).round(2)
  end

  # Get cinstance of this plan bought by given user account.
  def cinstance_bought_by(account)
    cinstances.bought_by(account).first
  end

  # Enable feature with given name (system_name, can be symbol)
  def enable_feature!(name)
    unless feature_enabled?(name)
      self.features_plans.create :feature => service.features.find_by_system_name!(name.to_s)
    end
  end

  def disable_feature!(name)
    features.delete(service.features.find_by_system_name!(name.to_s))
  end

  def feature_enabled?(name)
    features.any? { |feature| feature.system_name == name.to_s }
  end

  def master?
    method = "default_#{self.class.to_s.underscore}"
    issuer.try!(method) == self
  end

  def to_xml(options = {})
    attrs = self.master? ? { :default => true } : {}
    xml_builder(options, attrs).to_xml
  end

  #TODO: test
  def usage_limits_for_widget
    self.usage_limits.includes(metric: :parent).order(:value).group_by(&:metric)
  end

  def pricing_rules_for_widget
    self.pricing_rules.includes(metric: :parent).group_by(&:metric)
  end

  #TODO: test
  def metrics_without_limits
    metrics_with_limits = Set.new self.usage_limits.includes(:metric).map(&:metric)
    all_metrics_of_plan = Set.new self.metrics
    return (all_metrics_of_plan -  metrics_with_limits).to_a
  end

  def set_state_to_hidden_if_nil
    self.state ||= 'hidden'
  end

  # TODO: test what happens when you try to buy an already bought plan
  #
  def create_contract_with(buyer, opts = nil)
    params = opts || {}

    contract = contracts.build params
    contract.application_id = params["application_id"] if params["application_id"]
    contract.user_key = params["user_key"] if params["user_key"]
    if buyer.new_record?
      # only build contract - it will be saved with account
      buyer.contracts << contract
      contract
    else
      # create contract directly from plan object
      contract.user_account_id = buyer.id
      contract.save
      contract
    end
  end

  # Same as +create_contract_with+, but
  #
  #  - raises an exception on validation failure
  #  - cannot be called on unsaved plan
  #
  def create_contract_with!(buyer, opts = nil)
    opts ||= {}
    new_contract = contracts.new opts
    new_contract.application_id = opts["application_id"] if opts["application_id"]
    new_contract.user_key = opts["user_key"] if opts["user_key"]
    new_contract.user_account_id = buyer.id # this attribute is now protected
    new_contract.save!
    new_contract
  end

  # pricing is enabled when provider's billing strategy is not nil
  def pricing_enabled?
    provider_account.billing_strategy && !provider_account.master_on_premises?
  end

  def limits
    plan_rule ? plan_rule.limits.to_h : {}
  end

  def switches
    plan_rule ? plan_rule.switches : []
  end

  def scheduled_for_deletion?
    !issuer || issuer.deleted? || provider_account&.scheduled_for_deletion?
  end

  protected

  def xml_builder(options, attrs = {}, extra_nodes = {})
    xml = options[:builder] || ThreeScale::XML::Builder.new

    xml.plan(attrs) do |xml|
      xml.id_ id unless new_record?
      xml.name  name
      xml.type_  self.class.to_s.underscore
      xml.state state
      xml.approval_required approval_required

      xml.setup_fee setup_fee
      xml.cost_per_month cost_per_month
      xml.trial_period_days trial_period_days
      xml.cancellation_period cancellation_period

      extra_nodes.each do |key,value|
        xml.__send__(:method_missing, key, value)
      end
    end
    xml
  end

  def money_in_currency(amount)
    amount.try!(:to_has_money, currency)
  end

  def clone_associations(custom)
    features.each do |feature|
      custom.features_plans.build :feature => feature
    end
  end

  private

  # act_as_list updates the position every time that a plan is destroyed.
  # But we do not want to do that when its issuer is going to be deleted anyway.
  # Additionally, we cannot do: skip_callback :destroy, :after, :decrement_positions_on_lower_items, if: -> { destroyed_by_association }
  # because it is an 'after' callback and by the time it is executed, destroyed_by_association is already 'nil'
  def act_as_list_no_update?
    super || scheduled_for_deletion?
  end

  def plan_rule
    @plan_rule ||= PlanRulesCollection.find_for_plan(self)
  end

  def generate_copy_system_name
    separator = '_copy_'.freeze
    base, _   = system_name.split(separator, 2)

    [base.first(200), randomized].join(separator)
  end
end
