class ServiceContract < Contract
  include Logic::Contracting::ServiceContract

  before_create :accept_on_create, :on => :create, :unless => :live?

  before_create :set_service_id
  before_validation :set_service_id
  attr_readonly :service_id

  belongs_to :service_plan, :foreign_key => :plan_id
  has_one :service, :through => :service_plan

  scope :by_service, ->(service) do
    where(:issuer_type => service.class.model_name.to_s, :issuer_id => service.id)
  end

  alias service issuer
  alias service_plan plan

  include ThreeScale::Search::Scopes

  self.allowed_sort_columns = %w{ cinstances.state accounts.org_name cinstances.created_at } # can't order by plans.name, service.name - mysql blows up
  self.allowed_search_scopes = %w{ service_id plan_id plan_type state account account_query state name }
  self.sort_columns_joins = {
    'accounts.org_name' => [:user_account],
    'plans.name' => [:application_plan],
    'service.name' => [:service]
  }

  scope :by_service_id, ->(service_id) do
    where(:plans => { :issuer_id => service_id.to_i }).joins(:plan).references(:plan)
  end


  # HACK: to enable it on-fly just when it comes from controller
  #
  def legal_terms_acceptance_on!
    @legal_terms_acceptance = true
  end

  protected

  def set_service_id
    self.service_id ||= plan.try(:issuer_id)
  end

  def correct_plan_subclass?
    unless self.plan.is_a? ServicePlan
      errors.add(:plan, 'plan must be a ServicePlan')
    end
  end

  def legal_terms_acceptance_on?
    @legal_terms_acceptance
  end

end
