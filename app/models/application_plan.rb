
class ApplicationPlan < Plan
  include ::ThreeScale::MethodTracing

  #TODO: is the dependent :destroy working?
  has_many :cinstances, :foreign_key => :plan_id, :dependent => :destroy, :inverse_of => :plan
  alias contracts             cinstances
  alias application_contracts cinstances

  belongs_to :partner
  belongs_to :service, :foreign_key => :issuer_id, :inverse_of => :application_plans

  validate :end_users_switch

  scope :provided_by, lambda { |provider|
    if provider == :all || provider.blank?
      {}
    else
      where(services: { account_id: provider }).joins(:service).references(:service).readonly(false)
    end
  }

  delegate :metrics, :to => :service

  scope :enterprise, -> { where.has { (system_name =~ '%enterprise%') } }

  DEFAULT_CONTRACT_OPTIONS = { :name => '%s\'s App', :description => 'Default application created on signup.' }.freeze

  def provider_account
    issuer && issuer.account
  end

  def master?
    issuer.try!(:default_application_plan) == self
  end

  def create_contract_with(buyer, opts = nil)
    opts ||= default_options_for(buyer)
    super(buyer, opts)
  end

  def create_contract_with!(buyer, opts = nil)
    opts ||= default_options_for(buyer)
    super(buyer, opts)
  end

  def to_xml(options = {})
    xml = options[:builder] || ThreeScale::XML::Builder.new

    attrs = {
      :custom => self.customized?,
      :default => self.master?
    }

    xml.plan(attrs) do |xml|
      xml.id_ id unless new_record?
      xml.name name
      xml.type_ self.class.to_s.underscore
      xml.state state
      xml.service_id issuer_id

      xml.end_user_required end_user_required

      xml.setup_fee setup_fee
      xml.cost_per_month cost_per_month
      xml.trial_period_days trial_period_days
      xml.cancellation_period cancellation_period
    end

    xml.to_xml
  end

  add_three_scale_method_tracer :to_xml, 'ActiveRecord/ApplicationPlan/to_xml'

  protected

  def clone_associations(custom)
    super

    pricing_rules.each do |pricing_rule|
      cloned_pricing_rule = pricing_rule.dup
      cloned_pricing_rule.plan = nil

      custom.pricing_rules << cloned_pricing_rule
    end

    usage_limits.each do |usage_limit|
      cloned_usage_limit = usage_limit.dup
      cloned_usage_limit.plan = custom

      custom.usage_limits << cloned_usage_limit
    end

    plan_metrics.each do |plan_metric|
      cloned_plan_metric = plan_metric.dup
      cloned_plan_metric.plan = custom

      custom.plan_metrics << cloned_plan_metric
    end

  end

  private

  def end_users_switch
    return unless issuer.try!(:account)
    switch = issuer.account.settings.end_users

    if end_user_required && (not switch.allowed?)
      errors.add(:end_user_required, :not_allowed)
    end
  end

  def default_options_for buyer
    DEFAULT_CONTRACT_OPTIONS.inject({}){|memo, (k,v)| memo[k] = sprintf(v, buyer.org_name); memo}
  end

end
