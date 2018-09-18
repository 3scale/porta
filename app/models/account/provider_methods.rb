module Account::ProviderMethods
  extend ActiveSupport::Concern

  included do
    attr_writer :signup

    with_options if: :require_billing_information?, presence: true do |rbi|
      rbi.validates :org_legaladdress
      rbi.validates :country
      rbi.validates :state_region
      rbi.validates :city
      rbi.validates :zip
    end

    validates :self_domain, uniqueness: { allow_nil: true, case_sensitive: false }
    has_one :go_live_state

    has_one :provider_constraints, foreign_key: 'provider_id'

    has_one :forum
    lazy_initialization_for :forum, if: :provider?

    has_one  :web_hook, inverse_of: :account
    has_many :alerts

    has_many :provider_audits, foreign_key: :provider_id, class_name: Audited.audit_class.name

    has_many :usage_limits, through: :services
    has_many :metrics, through: :services
    has_many :proxies, through: :services
    has_many :proxy_logs, foreign_key: :provider_id
    has_many :authentication_providers, -> { developer }, dependent: :destroy, inverse_of: :account do
      def build_kind(kind:, **attributes)
        complete_attributes = attributes.merge(account: build.account).symbolize_keys!
        build_by_kind(kind: kind, account_type: AuthenticationProvider.account_types[:developer], **complete_attributes)
      end
    end
    has_many :self_authentication_providers, -> { provider }, dependent: :destroy, class_name: 'AuthenticationProvider', inverse_of: :account do
      def build_kind(kind:, **attributes)
        complete_attributes = attributes.merge(account: build.account).reverse_merge(where_values_hash).symbolize_keys!
        build_by_kind(kind: kind, account_type: AuthenticationProvider.account_types[:provider], **complete_attributes)
      end
    end

    has_attached_file :proxy_configs, storage: :s3, path: '.sandbox_proxy/sandbox_proxy_:id.lua'
    do_not_validate_attachment_file_type :proxy_configs

    has_attached_file :proxy_configs_conf, storage: :s3, path: '.sandbox_proxy_confs/sandbox_proxy_:id.conf'
    do_not_validate_attachment_file_type :proxy_configs_conf

    unless defined?(::Aws::S3)
      ## Fallback for not working s3.

      class FakeAttachment < Paperclip::Attachment
        def initialize_storage; end
        def flush_deletes; end
        def flush_writes; end
      end

      def proxy_configs_with_rescue
        proxy_configs_without_rescue
      rescue LoadError
        FakeAttachment.new(:proxy_configs, self)
      end

      def proxy_configs_conf_with_rescue
        proxy_configs_conf_without_rescue
      rescue LoadError
        FakeAttachment.new(:proxy_configs_conf, self)
      end

      alias_method_chain :proxy_configs, :rescue
      alias_method_chain :proxy_configs_conf, :rescue
    end


    has_many :buyer_accounts, class_name: 'Account', foreign_key: 'provider_account_id', dependent: :destroy, inverse_of: :provider_account do
      def latest
        order(created_at: :desc).includes([:admin_users]).limit(5)
      end
    end

    alias_method :buyers, :buyer_accounts
    has_many :buyer_users, through: :buyer_accounts, source: :users
    has_many :buyer_applications, through: :buyer_accounts, source: :bought_cinstances

    has_one :billing_strategy, class_name: 'Finance::BillingStrategy', inverse_of: :account, dependent: :destroy

    has_many :buyer_invoices, class_name: 'Invoice', foreign_key: :provider_account_id
    has_many :buyer_invoice_counters, class_name: 'InvoiceCounter', foreign_key: :provider_account_id
    has_many :buyer_line_items, through: :buyer_invoices, source: :line_items
    has_many :buyer_invitations, through: :buyer_accounts, source: :invitations

    module FindOrDefault
      def find_or_default(id = nil)
        owner = proxy_association.owner
        raise ProviderOnlyMethodCalledError if owner.buyer?

        # TODO
        # in Service#update_account_default_service default_service_id has been updated
        # but account.object_id != owner.object_id (inverse_of is needed)
        # because default_service_id may not exist anymore
        id ||= owner.try!(:default_service_id)
        id ? find_by_id(id) : first
      end

      alias default find_or_default
    end

    has_many :services, dependent: :destroy, extend: FindOrDefault
    has_many :accessible_services, -> { accessible }, class_name: 'Service', extend: FindOrDefault
    has_many :accessible_proxies, through: :accessible_services, source: :proxy
    has_many :accessible_proxy_configs, through: :accessible_proxies, source: :proxy_configs

    has_many :service_plans, through: :services
    has_many :application_plans, through: :services do
      def default
        proxy_association.owner.default_application_plans
      end
    end

    has_many :end_user_plans, through: :services
    has_many :account_plans, as: :issuer,  inverse_of: :provider, dependent: :destroy, &DefaultPlanProxy
    has_many :issued_plans, as: :issuer, class_name: 'Plan'

    has_many :default_service_plans, through: :services, class_name: 'ServicePlan'
    has_many :default_application_plans, through: :services, class_name: 'ApplicationPlan'
    has_many :default_end_user_plans, through: :services, class_name: 'EndUserPlan'
    belongs_to :default_account_plan, class_name: 'AccountPlan'

    has_many :fields_definitions, -> { by_position }, inverse_of: :account do
      def by_target(kind)
        grouped_by_target[kind.downcase]
      end

      private

      def grouped_by_target
        @by_target ||= Hash.new do |hash, target|
          hash[target] = select{ |fd| fd.target.downcase == target }
        end
      end
    end

    has_many :service_contracts, through: :services
    def services_without_contracts(user_account)
      services.where.not(id: service_contracts.where(user_account_id: user_account.id).select('service_id as id'))
    end

    scope :with_billing, -> { joins(:billing_strategy) }

    after_create :create_first_service, if: :provider?, unless: :master?
    after_create :create_default_fields_definitions, :create_go_live_state, if: :provider?

    include RedhatCustomerPortalSupport
  end

  class ProviderOnlyMethodCalledError < StandardError; end
  class MasterOnlyMethodCalledError < StandardError; end

  module ClassMethods
  end

  DEFAULT_CURRENCY = 'EUR'

  # Only timezones with whole hour shift are allowed
  #
  ALLOWED_TIMEZONES = ActiveSupport::TimeZone.all.reject { |z| z.utc_offset % 3600 != 0 }.freeze

  # Returns all alerts for all the apps of this provider buyers minus his own with (master) 3scale
  #
  def buyer_alerts
    alerts.where(["alerts.cinstance_id != ?", bought_cinstance.id])
  rescue Account::BuyerMethods::ApplicationNotFound
    alerts
  end

  delegate :password_login_allowed?, to: :settings

  def provider_key
    ensure_provider
    self.bought_cinstances.first!.user_key
  end

  alias api_key provider_key

  def partner?
    partner_id.present?
  end

  # @return [Array<AuthenticationProvider>]
  def authentication_provider_kinds
    available = AuthenticationProvider.available
    indexed = authentication_providers.where(type: available).group_by(&:type)

    available.each do |model|
      unless indexed[model.name].present?
        indexed[model.name] = model.new
      end
    end

    indexed.values.flatten.sort_by{ |a| a.to_param.to_s }.reverse
  end

  def provided_cinstances
    Cinstance.provided_by self
  end

  def provided_contracts
    Contract.provided_by self
  end

  def provided_service_contracts
    ServiceContract.provided_by self
  end

  def provided_plans
    Plan.provided_by self
  end

  def published_application_plans
    application_plans.published
  end

  def admin_domain
    if provider?
      if self_domain.present?
        self_domain
      else # connect case
        Account.master.domain
      end
    else
      raise ProviderOnlyMethodCalledError
    end
  end

  def require_billing_information!
    @require_billing_information = true
  end

  def require_billing_information?
    @require_billing_information
  end

  # REFACTOR: if it would be on an association proxy of services, it
  # would be cooler - provider.accessible_services.default
  #
  def default_service
    @default_service ||= accessible_services.default
  end

  def is_billing_buyers?
    !billing_strategy.nil?
  end

  def available_provider_groups
    provided_groups_for_providers
  end

  def s3_provider_prefix
    bucket_owner = provider? ? self : provider_account
    bucket_owner.try(:s3_prefix).try(:parameterize).to_s
  end

  def from_email
    self[:from_email] || Rails.configuration.three_scale.noreply_email
  end

  def show_xss_protection_options?
    !settings.cms_escape_draft_html? || !settings.cms_escape_published_html?
  end

  def customer
    ::Customer.new(
      first_name: billing_address_first_name,
      last_name: billing_address_last_name,
      phone: billing_address_phone
    )
  end

  def billing_address_data
    ::BillingAddress.new(
      company: billing_address_name,
      street_address: billing_address_address1,
      locality: billing_address_city,
      country_name: billing_address_country,
      region: billing_address_state,
      postal_code: billing_address_zip
    )
  end

  def provider_constraints
    super or ProviderConstraints.null(self)
  end

  # This is a replacement of services.default
  def first_service
    accessible_services.first
  end

  def first_service!
    accessible_services.first!
  end

  def create_service(attrs)
    services.build do |service|
      service.update_attributes(attrs)
    end
  end

  protected

  def create_first_service
    return if @signup_mode

    unless self.bought_cinstances.exists?
      application_plans = Account.master.accessible_services.default.application_plans
      plan = application_plans.default || application_plans.first!
      plan.create_contract_with!(self)
    end

    services.create! name: "API"
  end

  def create_default_fields_definitions
    # we don't do this for master to avoid slow things more
    # reason of the unless : Account.master.provider? => true
    FieldsDefinition.create_defaults(self) unless master?
  end

  private

  def ensure_provider
    raise ProviderOnlyMethodCalledError if self.buyer?
  end

  def ensure_master
    raise MasterOnlyMethodCalledError unless self.master?
  end

end
