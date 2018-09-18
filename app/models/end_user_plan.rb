class EndUserPlan < ApplicationRecord
  include Logic::MetricVisibility::Plan
  include ThreeScale::Search::Scopes

  belongs_to :service, :inverse_of => :end_user_plans

  alias_attribute :issuer, :service
  alias_attribute :issuer_id, :service_id

  has_many :metrics, :through => :service

  with_options(as: :plan, dependent: :destroy, foreign_key: :plan_id) do |plan|
    plan.has_many :usage_limits, &Logic::MetricVisibility::OfMetricAssociationProxy
    plan.has_many :plan_metrics, &Logic::MetricVisibility::OfMetricAssociationProxy
  end

  validates :service, :name, presence: true
  # TODO: this scope might be just :service_id, depends on how it is implemented in backend
  validates :name, uniqueness: { :scope => [:service_id] }

  after_create :mark_as_default_if_needed
  after_update :update_service_if_needed

  attr_accessible :service, :name

  ID_PREFIX = 'up_'

  def provider_account
    service.account
  end

  def pricing_enabled?
    false
  end

  def can_be_destroyed?
    false # TODO: handle deletion
  end

  def backend_id
    self.class.prefix_id(id)
  end

  def default?
    service.default_end_user_plan_id == id
  end

  def to_xml(options = {})
    xml = options[:builder] || ThreeScale::XML::Builder.new

    attrs = {}
    attrs[:default] = true if default?

    xml.end_user_plan(attrs) do |xml|
      xml.id_ id
      xml.created_at created_at.xmlschema
      xml.updated_at updated_at.xmlschema

      xml.service_id service_id

      xml.name name
    end

    xml.to_xml
  end

  def default!
    service.update_attribute(:default_end_user_plan, self)
  end

  class << self

    def prefix_id(id)
      ID_PREFIX + id.to_s if id
    end

    def unprefix_id(id)
      id.to_s.sub(/^#{ID_PREFIX}/, '').presence
    end
  end

  private

  def update_service_if_needed
    if self.name_changed?
      # foce updating service to backend even if plan_id wasnt changed
      # service stores also name of plan
      self.service.update_backend_service
    end
  end

  def mark_as_default_if_needed
    default! if service.end_user_plans == [self]
  end

end
