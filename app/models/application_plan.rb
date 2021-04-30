
class ApplicationPlan < Plan

  #TODO: is the dependent :destroy working?
  has_many :cinstances, :foreign_key => :plan_id, :dependent => :destroy, :inverse_of => :plan
  alias contracts             cinstances
  alias application_contracts cinstances

  belongs_to :partner
  belongs_to :service, :foreign_key => :issuer_id, :inverse_of => :application_plans

  scope :provided_by, ->(provider) {
    if provider == :all || provider.blank?
      {}
    else
      where(services: { account_id: provider.id }).joins(:service).references(:service).readonly(false)
    end
  }

  delegate :metrics, :all_metrics, :to => :service

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
    attrs = {
      :custom => self.customized?,
      :default => self.master?
    }
    extra_nodes = {
      service_id: issuer_id
    }
    xml_builder(options, attrs, extra_nodes).to_xml
  end


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

  def default_options_for buyer
    DEFAULT_CONTRACT_OPTIONS.inject({}){|memo, (k,v)| memo[k] = sprintf(v, buyer.org_name); memo}
  end

end
