# frozen_string_literal: true

class ServicePlan < Plan

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
    attrs = self.master? ? { :default => true } : {}
    extra_nodes = {
      service_id: issuer_id
    }
    xml_builder(options, attrs, extra_nodes).to_xml
  end

end
