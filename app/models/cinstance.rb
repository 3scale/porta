class Cinstance < Contract
  # Maximum number of cinstances permitted between provider and buyer
  MAX = 10

  delegate :backend_version, to: :service, allow_nil: true

  belongs_to :plan, class_name: 'ApplicationPlan', foreign_key: :plan_id, inverse_of: :cinstances, counter_cache: :contracts_count
  alias application_plan plan

  # TODO: verify the comment is still true and we can't use inverse_of
  belongs_to :service #, inverse_of: :cinstances # this inverse_of messes up some association autosave stuff

  has_many :alerts
  has_many :line_items

  # this needs to be before the include Backend::ModelExtensions::Cinstance
  # otherwise the application is deleted from backend before the appplication keys are removed, producing errors
  with_options(foreign_key: :application_id, dependent: :destroy, inverse_of: :application) do |backend|
    backend.has_many :referrer_filters, &::ReferrerFilter::AssociationExtension
    backend.has_many :application_keys, &::ApplicationKey::AssociationExtension
  end

  before_create :set_user_key
  before_create :set_service_id
  before_validation :set_service_id
  before_create :set_provider_public_key
  before_create :set_end_user_required_from_plan
  before_create :accept_on_create, :unless => :live?

  attr_readonly :service_id

  include WebHooksHelpers #TODO: make this inclusion more dsl-ish
  fires_human_web_hooks_on_events

  # this has to be before the include Backend::ModelExtensions::Cinstance
  # or callbacks order makes keys not to be saved in backend
  after_save :create_first_key, on: :create

  # before_destroy :refund_fixed_cost
  after_commit :reject_if_pending, :on => :destroy

  include Logic::Contracting::ApplicationContract

  # FIXME: including Fields after other includes makes Fields break
  include Fields::Fields
  required_fields_are :name, :description
  set_fields_account_source :user_account

  include Backend::ModelExtensions::Cinstance
  include Finance::VariableCost
  include Logic::Authentication::ApplicationContract
  include Logic::Keys::ApplicationContract
  include Logic::EndUsers::ApplicationContract

  include ThreeScale::Search::Scopes

  def self.attributes_for_destroy_list
    %w( id user_account_id name description user_key plan_id state trial_period_expires_at created_at extra_fields)
  end

  self.allowed_sort_columns = %w{ cinstances.name cinstances.state accounts.org_name cinstances.created_at cinstances.first_daily_traffic_at } # can't order by plans.name, service.name - mysql blows up
  self.default_sort_column = :created_at
  self.default_sort_direction = :desc
  self.allowed_search_scopes = %w{ service_id plan_id plan_type state account account_query state name user_key active_since inactive_since }
  self.default_search_scopes = { }
  self.sort_columns_joins = {
    'accounts.org_name' => [:user_account],
    'plans.name' => [:plan],
    'service.name' => [:service]
  }

  def redirect_url=(redirect_url)
    super(redirect_url.try(:strip))
  end

  validates :conditions,
    acceptance: { :message => 'you should agree on the terms and conditions for this plan first' }

  validates :plan, presence: true
  validates :name,        presence: { :if => :name_required? }
  validates :description, presence: { :if => :description_required? }

  after_commit :push_webhook_key_updated, :on => :update, :if => :user_key_updated?
  after_save :push_application_updated_event, on: :update

  #this method marks that a human edition of the app is happening, thus description presence will be validated
  # this is done so e.g. to avoid change_plan to fail when the app misses description or name
  def validate_human_edition!
    @validate_human_edition = true
  end

  def validate_plan_is_unique!
    @validate_plan_is_unique = true
  end

  def validate_plan_is_unique?
    @validate_plan_is_unique
  end

  validate :plan_is_unique, if: :validate_plan_is_unique?
  validate :application_id_is_unique, if: :validate_application_id_is_unique?
  validates :application_id, uniqueness: { scope: [:service_id] }, unless: :validate_application_id_is_unique?

  validate :user_key_is_unique, unless: :provider_can_duplicate_user_key?

  validates :user_key, uniqueness: { scope: [:service_id] }, if: :provider_can_duplicate_user_key?

  validate :end_users_switch

  APP_ID_FORMAT = /[\w-]+/.freeze
  # letter, number, underscore (_), hyphen-minus (-), dot (.), base64 format
  # In base64 encoding, the character set is [A-Z,a-z,0-9,and + /], if rest length is less than 4, fill of '=' character.
  # ^([A-Za-z0-9+/]{4})* means the String start with 0 time or more base64 group.
  # ([A-Za-z0-9+/]{4}|[A-Za-z0-9+/]{3}=|[A-Za-z0-9+/]{2}==) means the String must end of 3 forms in [A-Za-z0-9+/]{4} or [A-Za-z0-9+/]{3}= or [A-Za-z0-9+/]{2}==
  # matches also the non 64B case with (\A[\w\-\.]+\Z)
  USER_KEY_FORMAT = /(([\w\-\.]+)|([A-Za-z0-9+\/]{4})*([A-Za-z0-9+\/]{4}|[A-Za-z0-9+\/]{3}=|[A-Za-z0-9+\/]{2}==))/

  # Arbitrary limit, increase don't broke anything.
  validates :application_id, format: { with: /\A#{APP_ID_FORMAT}\Z/ }, length: { in: 4..140 }


  validates :user_key, format: { with: /\A#{USER_KEY_FORMAT}\Z/ }, length: { maximum: 256 },
            allow_nil: true, allow_blank: true

  scope :order_for_dev_portal, -> { order(service_id: :desc, created_at: :desc) }

  # Return only live cinstances
  #
  # Note that deprecated cinstances are still considered live. This is
  # intentional, because deprecated cinstances can still be used (so they are
  # "live", in a way).
  scope :live, -> { where(:state => ['live', 'deprecated'])}

  # Return only cinstances live at given time. The time can be single time or
  # period (Range object) (from..to).
  scope :live_at, lambda { |period|
    period = period..period unless period.is_a?(Range)

    where(['cinstances.created_at <= ?', period.end])
  }

  def self.provided_by(account)
    joins(:service).references(:service).merge(Service.of_account(account)).readonly(false)
  end

  scope :can_be_managed, lambda {
                           includes(plan: :service)
                              .where(['services.buyers_manage_apps = ?', true])
                              .references(:services)
  }
  scope :latest, -> (count = 5) { reorder(created_at: :desc).limit(count)}
  scope :by_user_key, lambda { |user_key| where({:user_key => user_key}) }
  scope :by_name, ->(query) do
    case query.strip
    when /\Auser_key:\s*#{Cinstance::USER_KEY_FORMAT}\z/ then by_user_key($1)
    else all.merge(Contract.by_name(query))
    end
  end
  scope :by_application_id, lambda { |app_id| where({:application_id => app_id}) }

  def self.by_service(service)
    if service == :all || service.blank?
      all
    else
      where{ plan_id.in( my{Plan.issued_by(service).select(:id)} ) }
    end
  end

  scope :by_service_id, lambda { |service_id|
    where(service_id: service_id)
  }

  scope :by_active_since, lambda {|date| where('first_daily_traffic_at >= ?', date) }
  scope :by_inactive_since, lambda {|date| where('first_daily_traffic_at <= ?', date) }

  ##
  #  Instance Methods
  #  and other stuff :(
  ##

  # maybe move both limit methods to their models?

  def self.serialization_preloading
    includes(:application_keys, :plan, :user_account,
             service: [:account, :default_application_plan])
  end


  def keys_limit
    case service.try(:backend_version)
    when 'oauth'
      1
    else
      ApplicationKey::KEYS_LIMIT
    end
  end

  def filters_limit
    ReferrerFilter::REFERRER_FILTERS_LIMIT
  end

  def buyer_alerts_enabled?
    service && service.notify_alerts?(:buyer, :web)
  end

  def period
    created_at..Time.zone.now
  end

  def display_name
    name.present? ? name : default_name
  end

  def default_name
    "Application on plan #{plan.name}"
  end

  delegate :provided_by?, to: :plan

  # Time value. paid until that Exact time
  def variable_cost_paid_until
    self[:variable_cost_paid_until] || trial_period_expires_at || created_at
  end

  # Shortcut for plan.service.metrics
  def metrics
    service && service.metrics
  end

  # Is this cinstance bought by an account?
  def bought_by?(account)
    buyer == account
  end

  def change_provider_public_key!
    update_attribute(:provider_public_key, generate_key)
  end

  def change_user_key!
    @webhook_event = 'user_key_updated'
    update_attribute(:user_key, generate_key)
  end

  def user_key_updated?
    self.previous_changes.select { |a| a == "user_key"}.count > 0
  end

  def push_webhook_key_updated
    #Push only if updated by User
    self.web_hook_event!({user: User.current, event: "key_updated"}) if User.current
  end

  def push_application_updated_event
    Applications::ApplicationUpdatedEvent.create_and_publish!(self)
  end

  # Reson why cinstance was rejected. This is only set after +reject!+ is called
  attr_reader :rejection_reason

  # Reject pending cinstance.
  #
  # Note that this is just convenience method equivalent to:
  #   cinstance.rejection_reason = "i don't like your mother"
  #   cinstance.destroy
  def reject!(reason)
    @rejection_reason = reason
    destroy
  end

  def select_users
    service.cinstances.collect {|c| [ c.user_name, c.id ] }
  end

  def available_application_plans
    plans_table   = Plan.table_name
    stock_not_mine = ["(#{plans_table}.original_id = 0 OR
                       #{plans_table}.original_id IS NULL) AND
                       #{plans_table}.id <> ?", plan_id]

    service.application_plans.where(stock_not_mine)
  end

  # Get a usage status object for this cinstance. This object contains information about
  # how close this cinstance is to it's usage limits. See ServiceTransaction::Status for
  # more details.
  def usage_status(options = {})
    Backend::Transaction.usage_status(provider_account, self, service, options)
  end

  def to_xml(options = {})
    result = options[:builder] || ThreeScale::XML::Builder.new

    result.application do |xml|
      unless new_record?
        xml.id_ id
        xml.created_at created_at.xmlschema
        xml.updated_at updated_at.xmlschema
      end
      xml.state state

      xml.user_account_id user_account_id
      xml.first_traffic_at first_traffic_at.try(:xmlschema)
      xml.first_daily_traffic_at first_daily_traffic_at.try(:xmlschema)
      xml.end_user_required end_user_required
      xml.service_id service.id if service.present?
      if service.backend_version.v1?
        xml.user_key( user_key )
        xml.provider_verification_key( provider_public_key )

      else #v2, oauth on enterprise
        xml.application_id( application_id )

        if service.backend_version.oauth?
          xml.redirect_url redirect_url
        end

        unless destroyed?
          xml.keys do |keys_element|
            keys.each do |k|
              keys_element.key k
            end
          end
        end
      end

      plan.to_xml(:builder => xml)

      unless destroyed?
        fields_to_xml(xml)
        extra_fields_to_xml(xml)

        if persisted?
          if referrer_filters_required?
            xml.referrer_filters do |referer_filters_element|
              referrers.each do |rf|
                referer_filters_element.referrer_filter(rf)
              end
            end
          end
        end
      end
    end

    result.to_xml
  end

  delegate :custom_keys_enabled?, :referrer_filters_required?, :to => :service

  def reload(*)
    super
  ensure
    @backend_object = nil
    @validate_human_edition = nil
  end

  def backend_object
    @backend_object ||= provider_account.backend_object.application(self)
  end

  def create_origin
    origin = self[:create_origin]
    ActiveSupport::StringInquirer.new(origin.to_s)
  end

  def keys
    application_keys.pluck_values
  end

  def referrers
    referrer_filters.pluck_values
  end

  def app_plan_change_should_request_credit_card?
    service.plan_change_permission(ApplicationPlan) == :request_credit_card
  end

  protected

  def correct_plan_subclass?
    unless self.plan.is_a? ApplicationPlan
      errors.add(:plan, 'plan must be an ApplicationPlan')
    end
  end

  private

  # It calls to `create_key_after_create` to check if it's possible to add
  # an application key.
  #
  # Return false if it isn't possible to create a first key
  def create_first_key
    create_key_after_create? ? application_keys.add : false
  end

  #
  # Overrides Contract protected method to run WebHooks after sucessful plan change
  #
  def change_plan_internal(new_plan)
    super do
      yield

      @webhook_event = 'plan_changed'
    end
  end

  def reject_if_pending
    notify_observers(:rejected) if pending?
  end

  def name_required?
    @validate_human_edition
  end

  def description_required?
    @validate_human_edition && (multiple_applications_allowed? || service_intentions_required?)
  end

  def service_intentions_required?
    issuer && issuer.intentions_required?
  end

  def multiple_applications_allowed?
    provider_account && provider_account.multiple_applications_allowed?
  end

  # Custom validation that assures that there is only one non-deleted cinstance
  # per plan and user account.
  #
  # TODO: maybe i can remove this and use regular validates_uniquenes_of?
  # validates_uniqueness_of :plan_id, :scope => [:user_account_id], :unless => :multiple_applications_allowed?, :message => 'is already bought'
  #
  # SURE! If you get rid of acts_as_paranoid because it has to be non-deleted and it keeps cinstances in this table

  def plan_is_unique
    if plan && user_account && !multiple_applications_allowed?
      # All non-deleted cinstance with the same user_account as this one...
      others = plan.cinstances.bought_by(user_account)

      # ...except this one (if already exists in database).
      others = others.without_ids(self.id) unless new_record?

      errors.add(:plan_id, 'is already bought') unless others.empty?
    end
  end

  def application_id_is_unique
    if provider_account
      others = provider_account.provided_cinstances.by_application_id(application_id)
      others = others.without_ids(self.id) unless new_record?
      errors.add(:application_id, :taken) unless others.empty?
    end
  end

  def validate_application_id_is_unique?
    !provider_account.try!(:provider_can_use?, :duplicate_application_id)
  end

  def provider_can_duplicate_user_key?
    provider_account.try!(:provider_can_use?, :duplicate_user_key)
  end

  def user_key_is_unique
    if provider_account
      others = provider_account.provided_cinstances.by_user_key(user_key)
      others = others.without_ids(self.id) unless new_record?
      errors.add(:user_key, :taken) unless others.empty?
    end
  end

  scope :without_ids, lambda { |id| where(["#{table_name}.id <> ?", id]) }

  def set_end_user_required_from_plan
    if end_user_required.nil?
      self.end_user_required = plan.try!(:end_user_required)
    end
    true
  end

  def set_user_key
    self.user_key ||= generate_key
  end

  def set_provider_public_key
    self.provider_public_key ||= generate_key
  end

  def set_service_id
    self.service_id ||= plan.try(:issuer_id)
  end

  def generate_key
    #FIXME: service is not accessible here yet
    plan.issuer.preffix_key(SecureRandom.hex(16))
  end

  def end_users_switch
    return unless plan
    switch = plan.issuer.account.settings.end_users

    if end_user_required && (not switch.allowed?)
      errors.add(:end_user_required, :not_allowed)
    end
  end
end

ApplicationContract = Cinstance
