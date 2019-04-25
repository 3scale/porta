class Feature < ApplicationRecord

  audited :allow_mass_assignment => true

  #TODO: these need tests
  #OPTIMIZE subclassing a better solution for these 2
  before_validation :try_to_set_scope
  validate :scope_matches_featurable?

  include SystemName
  has_system_name

  belongs_to :featurable, :polymorphic => true

  has_many :features_plans, :dependent => :delete_all
  has_many :plans, :through => :features_plans

  scope :visible, ->{ where(visible: true ) }
  scope :hidden, ->{ where(visible: false) }
  scope :with_object_scope, ->(object) do
    where(:scope => object.class.model_name.to_s)
  end

  attr_protected :featurable_id, :featurable_type, :tenant_id, :audit_ids

  validates :system_name, uniqueness: { :scope => [:featurable_id, :featurable_type] }
  validates :system_name, :name, length: { maximum: 255 }

  def hide!
    update_attribute(:visible, false)
  end

  def show!
    update_attribute(:visible, true)
  end

  def hidden?
    !visible?
  end

  def to_xml(options = {})
    xml = options[:builder] || ThreeScale::XML::Builder.new

    featurable_type_id = "#{self.featurable.class.to_s.downcase}_id"

    xml.feature do |xml|
      xml.id_ id unless new_record?
      xml.name name
      xml.system_name system_name
      xml.__send__(:method_missing, featurable_type_id, self.featurable.id)
      xml.scope scope.underscore
      xml.visible visible
      xml.description description
    end

    xml.to_xml
  end

  private

  #OPTIMIZE: subclassing a better solution for these 2
  def try_to_set_scope
    #this is a commodity method
    if self.featurable.is_a?(Account)
      self.scope = "AccountPlan"
    end
  end

  def scope_matches_featurable?
    case self.featurable
    when Account
      unless scope == "AccountPlan"
        errors.add :scope, "must be an AccountPlan"
      end
    when Service
      unless ["ApplicationPlan", "ServicePlan"].include?(scope)
        errors.add :scope, "must be ApplicationPlan or ServicePlan"
      end
    end
  end

  protected
  def provider_id_for_audits
    featurable.try!(:provider_id_for_audits) || featurable.try!(:tenant_id)
  end
end
