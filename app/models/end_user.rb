class EndUser
  include ActiveModel::Validations
  include ActiveModel::Conversion
  include ActiveModel::MassAssignmentSecurity
  extend ActiveModel::Naming

  attr_reader :backend_user
  attr_writer :username

  attr_accessible :username, :plan_id

  BACKEND_CLASS = ThreeScale::Core::User

  validates :username, :service, presence: true
  validates :username, format: /\A[a-zA-Z0-9\-\_\.]+\z/
  validates :plan, presence: { :if => :service_without_default_plan? }
  validates :username, length: { maximum: 200 }
  validate :uniqueness_of_username, :if => :new_record?

  class << self

    def find(service, username)
      return if username.blank?
      backend_user = BACKEND_CLASS.load(service.backend_id, username)

      if backend_user
        self.new(service, :backend_user => backend_user)
      end
    end

    def create(service, attributes)
      end_user = self.new(service, attributes)
      end_user.save
      end_user
    end

    def unscoped
      self
    end
  end

  def initialize service, attributes = {}
    @new_record = true
    @service = service
    self.backend_user = attributes.try!(:delete, :backend_user)
    self.attributes = attributes if attributes.present?
    self.plan ||= default_plan
  end

  # this exists for the purpose of fooling formtastic
  def id
    username
  end

  def attributes= attrs
    attrs = attrs.dup.with_indifferent_access
    @plan_id = find_plan(attrs[:plan_id]).try!(:id)
    @username = attrs[:username] if attrs[:username] && new_record?
  end

  def attributes
    {
      :service_id => service.try!(:backend_id),
      :plan_id => plan.try!(:backend_id),
      :plan_name => plan_name,
      :username => username
    }.reject { |k,v| v.nil? }
  end

  def save
    return false unless valid?
    self.backend_user = BACKEND_CLASS.save! attributes
  end

  def save!
    save || raise(ActiveRecord::RecordInvalid, self)
  end

  def update_attributes attributes
    self.attributes = attributes
    save
  end

  def destroy
    BACKEND_CLASS.delete!(service.backend_id, username)
    @destroyed = true
    errors # touch this before freezing object
    freeze
  end

  def plan_id
    @plan_id ||= EndUserPlan.unprefix_id(backend_user.try!(:plan_id))
    @plan_id.try!(:to_i)
  end

  def plan_name
    plan.try!(:name) or backend_user.try!(:plan_name)
  end

  def plan
    find_plan(plan_id)
  end

  def username
    @username ||= backend_user.try!(:username)
  end
  alias to_param username

  def service
    @service or @plan.try!(:service) or backend_user.try!(:service)
  end

  def plan= plan
    # ensure that the plan is from same service
    @plan_id = find_plan(plan.id).id if plan
  end

  def reload
    if backend_user
      new = self.class.find(service, username)
      self.backend_user = new.backend_user
      @plan_id = nil
      @username = nil
    end
    # TODO: do actual reloading
    self
  end

  def to_xml(options = {})
    xml = options[:builder] || ThreeScale::XML::Builder.new

    xml.end_user do |xml|
      xml.username username
      xml.plan_id plan_id
      xml.service_id service.id
    end

    xml.to_xml
  end

  def new_record?
    !!@new_record
  end

  def destroyed?
    @destroyed
  end

  def persisted?
    !(new_record? || destroyed?)
  end

  private

  def backend_user= user
    @backend_user = user and @new_record = false
    user
  end

  def find_plan(id)
    EndUserPlan.where(service: service).find(id) if id.present?
  end

  def service_without_default_plan?
    service.try!(:default_end_user_plan_id).nil?
  end

  def default_plan
    service.try!(:default_end_user_plan)
  end

  def uniqueness_of_username
    if username && service && self.class.find(service, username)
      errors.add :username, "is already used by another #{self.class.model_name.human}"
    end
  end

end
