
class ServicePlan < Plan
  include ::ThreeScale::MethodTracing

  #application_plan association has :dependent => :destroy why this one does not?
  has_many :service_contracts, :foreign_key => :plan_id
  alias contracts service_contracts

  belongs_to :service, :foreign_key => :issuer_id, :inverse_of => :service_plans

  before_destroy :destroy_contracts

  def provider_account
    service && service.account
  end

  def master?
    issuer.try!(:default_service_plan) == self
  end

  def destroy_contracts
    service_contracts.destroy_all
  end

  def to_xml(options = {})
    xml = options[:builder] || ThreeScale::XML::Builder.new

    attrs = if self.master?
              { :default => true }
            else
              { }
            end

    xml.plan(attrs) do |xml|
      xml.id_ id unless new_record?
      xml.name name
      xml.type_ self.class.to_s.underscore
      xml.state state
      xml.service_id issuer_id
      xml.approval_required approval_required

      xml.setup_fee setup_fee
      xml.cost_per_month cost_per_month
      xml.trial_period_days trial_period_days
      xml.cancellation_period cancellation_period
    end

    xml.to_xml
  end

  add_three_scale_method_tracer :to_xml, 'ActiveRecord/ServicePlan/to_xml'
end
