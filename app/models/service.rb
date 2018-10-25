require 'backend_client'

class Service < ApplicationRecord
  include Backend::ModelExtensions::Service
  include Logic::Contracting::Service
  include Logic::PlanChanges::Service
  include Logic::EndUsers::Service
  include Logic::Backend::Service
  include Logic::Authentication::Service
  include Logic::RollingUpdates::Service
  include SystemName
  extend System::Database::Scopes::IdOrSystemName
  include ServiceDiscovery::ModelExtensions::Service

  DELETE_STATE = 'deleted'.freeze

  has_system_name uniqueness_scope: :account_id

  attr_readonly :system_name

  validates :backend_version, inclusion: { in: BackendVersion::VERSIONS }

  include Authentication
  validates :support_email, format: { with: RE_EMAIL_OK, message: MSG_EMAIL_BAD,
                                      allow_blank: true }

  after_create :create_default_metrics, :create_default_service_plan, :create_default_proxy
  after_commit :update_notification_settings

  after_save :publish_events
  after_save :deleted_without_state_machine

  before_destroy :stop_destroy_if_last_or_default
  before_destroy :destroy_features
  after_destroy :update_account_default_service

  with_options(dependent: :destroy, inverse_of: :service) do |service|
    service.has_many :service_plans, as: :issuer, &DefaultPlanProxy
    service.has_many :application_plans, as: :issuer, &DefaultPlanProxy
    service.has_many :end_user_plans, &DefaultPlanProxy
    service.has_many :api_docs_services, class_name: 'ApiDocs::Service'
  end

  def self.columns
    super.reject { |column| column.name == 'buyer_can_see_log_requests'}
  end

  def self.of_account(account)
    where(account_id: account)
  end

  has_one :proxy, dependent: :destroy, inverse_of: :service, autosave: true

  belongs_to :default_service_plan, class_name: 'ServicePlan'
  belongs_to :default_application_plan, class_name: 'ApplicationPlan'
  belongs_to :default_end_user_plan, class_name: 'EndUserPlan'

  attr_protected :account_id, :tenant_id, :audit_ids

  # LEGACY
  alias plans application_plans

  has_many :issued_plans, as: :issuer, class_name: 'Plan'

  # for consistency with Provider
  alias provided_plans issued_plans

  has_many :cinstances, inverse_of: :service
  has_many :service_contracts, through: :service_plans #, :readonly => true

  has_many :contracts, through: :issued_plans do #, :readonly => true
    # rename or remove - does not return the expected thing
    def service
      by_type :ServiceContract
    end

    def cinstance
      by_type :Cinstance
    end

    alias_method :application, :cinstance
  end

  belongs_to :account
  alias provider account

  has_many :usage_limits, through: :application_plans

  has_many :features, as: :featurable

  has_many :metrics, dependent: :destroy
  has_many :top_level_metrics, -> { includes(:children).top_level }, class_name: 'Metric'

  has_many :service_tokens, inverse_of: :service, dependent: :destroy

  scope :accessible, -> { where.not(state: DELETE_STATE) }
  scope :of_approved_accounts, -> { joins(:account).merge(Account.approved) }
  scope(:permitted_for_user, lambda do |user|
    # TODO: this is probably wrong...
    # how come if it does not have access_to_all_services but it can not use service_permissions,
    # then we allow them all?!!
    # but this is keeping the same behaviour that it previously had
    if user.forbidden_some_services?
      where({id: user.member_permission_service_ids})
    else
      all
    end
  end)

  validates :tech_support_email, :admin_support_email, :credit_card_support_email, format: { with: /.+@.+\..+/, allow_blank: true }

  validates :name, presence: true

  validates :default_end_user_plan, presence: { unless: :end_user_registration_required? }
  validates :name, :logo_file_name, :logo_content_type, :state, :draft_name,
            :tech_support_email, :admin_support_email, :credit_card_support_email,
            :buyer_plan_change_permission, :system_name, :backend_version, :support_email, :deployment_option,
            length: { maximum: 255 }
  validates :infobar, :terms, :notification_settings, :oneline_description, :description,
            :txt_api, :txt_support, :txt_features,
            length: { maximum: 65535 }

  class DeploymentOption
    PLUGINS = %i(ruby java python nodejs php rest csharp).freeze
    private_constant :PLUGINS

    APICAST = %i(hosted self_managed).freeze
    private_constant :APICAST

    def self.plugins
      PLUGINS.map { |lang| "plugin_#{lang}".freeze }
    end

    def self.gateways
      gateways = APICAST - (ThreeScale.config.apicast_custom_url ? %i(self_managed) : [])
      gateways.map { |gateway| gateway.to_s.freeze }
    end
  end

  validates :deployment_option, inclusion: { in: DeploymentOption.plugins + DeploymentOption.gateways }, presence: true
  scope :deployed_with_gateway, -> { where(deployment_option: DeploymentOption.gateways) }

  validate :end_users_switch
  serialize :notification_settings

  audited allow_mass_assignment: true
  state_machine initial: :incomplete do
    state :incomplete
    state :hidden
    state :offline
    state :published
    state :deprecated # (soft) scheduled for deletion
    state :deleted # (hard) DELETED

    event :take_offline do
      transition published: :offline
    end

    # This is effectively the same as hide!, but the name is more descriptive.
    event :complete do
      transition incomplete: :hidden
    end

    event :reject do
      transition pending: :hidden
    end

    event :publish do
      transition [:offline, :pending, :incomplete, :hidden, :published] => :published
    end

    event :hide do
      transition [:incomplete, :published, :pending] => :hidden
    end

    event :deprecate do
      transition [:incomplete, :published, :offline, :hidden] => :deprecated
    end

    event :mark_as_deleted do
      transition [:incomplete, :published, :offline, :hidden] => :deleted, unless: :last_accessible?
    end

    before_transition to: [:deleted], do: :deleted_by_state_machine
    after_transition to: [:deleted], do: :notify_deletion
  end

  def using_proxy_pro?
    provider_can_use?(:proxy_pro) && proxy.self_managed?
  end

  def preffix
    @service_preffix ||= (provider.service_preffix || '')
  end

  # by GrammarNazi
  alias prefix preffix

  def publish_events
    OIDC::ServiceChangedEvent.create_and_publish!(self)
    OIDC::ProxyChangedEvent.create_and_publish!(proxy) if backend_version_change&.include?('oauth')
  end

  def backend_authentication_type
    if account.try!(:provider_can_use?, :apicast_per_service)
      :service_token
    else
      :provider_key
    end
  end

  def backend_authentication_value
    case type = backend_authentication_type
    when :service_token
      service_token
    when :provider_key
      account.try!(:provider_key)
    else
      raise "unknown backend_authentication_type: #{type}"
    end
  end

  # shouldn't be here .last (?)
  # rotation won't work
  def active_service_token
    service_tokens.first
  end

  def service_token
    active_service_token.try(:value)
  end

  def latest_applications
    cinstances.latest
  end

  def has_traffic?
    cinstances.where.not(first_traffic_at: nil).exists?
  end

  def proxiable?
    backend_version.is?(1, 2, :oauth)
  end

  def backend_version
    BackendVersion.new(super)
  end

  def preffix_key(key = id)
    [preffix.presence, key].compact.join
  end

  def published_plans
    application_plans.published
  end

  # use this method to destroy the default service with all callbacks firing
  def destroy_default
    @destroy_default_allowed = true
    destroy
  end

  def stop_destroy_if_last_or_default
    return if destroyable?
    errors.add :base, 'This service cannot be removed'
    false
  end

  def destroy_features
    features.destroy_all
  end

  # Returns either a service between that service and buyer account or nil.
  #
  # TODO: test this - used in 'Liquid::PlanWrapper'
  #
  def service_contract_of(buyer)
    service_contracts.find_by(user_account_id: buyer.id)
  end

  # Active service means that it has published service plan
  # convenience method
  def disabled?
    deprecated? || deleted?
  end

  # TODO: Migrate all the customers to use service_id on API calls
  # Then remove this notion of default_service
  def default?
    account.default_service_id == id
  end

  def plans_by_state(state)
    application_plans.by_state state
  end

  def provided_by?(account)
    self.account == account
  end

  def visible_plans_for(buyer_account)
    # TODO: convert this to a scope
    results = published_plans.to_a

    if buyer_account && !results.include?(buyer_account.bought_plan)
      results << buyer_account.bought_plan
    end

    results
  end

  # This returns true of false on whether a service has any published plans.
  def has_published_plans?
    application_plans.exists?("state = 'published' OR live_state = 'published'")
  end

  # Only those metrics that are methods.
  def method_metrics
    metrics.find_by(system_name: 'hits')&.children || metrics.none
  end

  # Does this service has metric "hits" with submetrics (methods) defined?
  def has_method_metrics?
    metrics.find_by(system_name: 'hits')&.parent?
  end

  def create_default_metrics
    metrics.create_default!(:hits, service_id: id)
  end

  def has_terms?
    terms.present?
  end

  # TODO: extract this and Cinstance.search into separate class
  # (CinstanceSearcher, or something like that)
  def search_cinstances(params)
    cinstances.with_account.by_state(params[:state]).search(params)
  end

  def reload(*)
    # Kill some cached stuff
    @cinstances = nil
    super
  end

  def to_xml(options = {})
    xml = options[:builder] || ThreeScale::XML::Builder.new

    xml.service do |xml|
      unless new_record?
        xml.id_ id
        xml.account_id account_id
      end
      xml.name name
      xml.state state
      xml.system_name system_name
      xml.backend_version proxy&.authentication_method
      xml.description description

      xml.deployment_option deployment_option
      xml.support_email support_email
      xml.tech_support_email tech_support_email
      xml.admin_support_email admin_support_email

      xml.end_user_registration_required end_user_registration_required

      metrics.to_xml(builder: xml, root: 'metrics')
    end

    xml.to_xml
  end

  # Reorder plans according to list of ids.
  #
  # == Example
  #
  # reorder_plans([3, 2, 1]) # will reorder plans so the one with
  # id=3 will be first, the one with id=2 second and the one with id=1
  # last.
  #
  def reorder_plans(ids)
    ids.each_with_index do |id, position|
      application_plans.find_by_id(id).update_attribute(:position, position)
    end
  end

  # Notification settings cleanup before assign
  # calling with nil removes all settings
  def notification_settings=(settings)
    if settings.present? # actualy some values were passed, so clean them and set them
      settings = settings.symbolize_keys
      settings.keys.each do |key|
        settings[key].map! &:to_i
      end

      self[:notification_settings] = settings
    else # nil was passed, so no values were set => clean settings
      self[:notification_settings] = {}
    end
  end

  def backend_object
    @backend_object ||= BackendClient::Connection.new.service(self)
  end

  def notify_alerts?(who, how)
    notification_settings.try!(:[], "#{how}_#{who}".to_sym).present?
  end

  def support_email
    se = self[:support_email]
    if se.present?
      se
    else
      account.try(:support_email)
    end
  end

  def mode_type
    return unless proxy

    if proxy.self_managed?
      if oauth?
        :oauth
      else
        :self_managed
      end
    else
      :hosted
    end
  end

  def last_accessible?
    !provider.accessible_services.where.not(id: id).exists?
  end

  # Backward compatibility with existing providers with default_service_id
  def default_or_last?
    default? || last_accessible?
  end

  def parameterized_name
    name.parameterize
  end

  def parameterized_system_name
    system_name.to_s.parameterize.tr('_','-')
  end

  APPLY_I18N = lambda do |args|
    args.map do |opt|
      [
        I18n.t(opt, scope: :deployment_options, raise: ActionView::Base.raise_on_missing_translations),
        opt
      ]
    end.to_h.freeze
  end
  private_constant :APPLY_I18N

  PLUGINS = APPLY_I18N.call(DeploymentOption.plugins)
  private_constant :PLUGINS

  def self.deployment_options(_)
    gateway = APPLY_I18N.call(DeploymentOption.gateways)

    { 'Gateway' => gateway, 'Plugin'  => PLUGINS }
  end

  def deployment_option=(value)
    super
  ensure
    # always set correct proxy endpoints when deployment option changes
    (proxy || build_proxy).try(:set_correct_endpoints) if deployment_option_changed?
  end

  def backend_version=(backend_version)
    (proxy || build_proxy).authentication_method = backend_version

    if oidc?
      super('oauth'.freeze)
    else
      super(backend_version)
    end
  end

  private

  def deleted_by_state_machine
    @deleted_by_state_machine = true
  end

  def deleted_without_state_machine
    if state_changed? && deleted? && !@deleted_by_state_machine
      System::ErrorReporting.report_error('Service has been deleted without using State Machine')
    end
  end

  def destroyable?
    return true if destroyed_by_association
    !default_or_last? || @destroy_default_allowed
  end

  def create_default_proxy
    create_proxy! unless proxy
  end

  def create_default_service_plan
    service_plans.create!(name: 'Default') { |plan| plan.state = default_service_plan_state }
  end

  def default_service_plan_state
    return unless account.try(:provider_can_use?, :published_service_plan_signup)
    account.settings.service_plans_ui_visible? ? 'hidden'.freeze : 'published'.freeze
  end

  def update_notification_settings
    return unless previously_changed?(:notification_settings)

    current_alert_limits = alert_limits

    delete_alert_limits(current_alert_limits - notification_settings_levels)
    create_alert_limits(notification_settings_levels - current_alert_limits)
  end

  def notification_settings_levels
    (notification_settings || {}).map { |_key, values| values }.flatten.uniq
  end

  def end_users_switch
    return unless account.try!(:settings)
    switch = account.settings.end_users

    if !end_user_registration_required && !switch.allowed?
      errors.add(:end_user_registration_required, :not_allowed)
    end
  end

  def alert_limits
    ThreeScale::Core::AlertLimit.load_all(backend_id).map(&:value)
  end

  def delete_alert_limits(*limits)
    limits.flatten.each do |limit|
      ThreeScale::Core::AlertLimit.delete(backend_id, limit)
    end
  end

  def create_alert_limits(*limits)
    limits.flatten.each do |limit|
      ThreeScale::Core::AlertLimit.save(backend_id, limit)
    end
  end

  def update_account_default_service
    # cannot use #default? method anymore (ActiveRecord::RecordNotFound)
    if account.default_service_id == id && !account.marked_for_destruction?
      account.update_columns(default_service_id: nil)
    end
  end

  protected

  # Create an event for scheduled deletion of service
  def notify_deletion
    Services::ServiceScheduledForDeletionEvent.create_and_publish!(self)
  end

  delegate :provider_id_for_audits, to: :account, allow_nil: true

  delegate :oauth?, to: :authentication_scheme?

  delegate :authentication_method, to: :proxy, prefix: true, allow_nil: true
  delegate :oidc?, to: :proxy, allow_nil: true

  def authentication_scheme?
    backend_version.to_s.inquiry
  end
end
