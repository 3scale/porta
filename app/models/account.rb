# frozen_string_literal: true

class Account < ApplicationRecord
  attribute :credit_card_expires_on, :date
  self.ignored_columns = %i[proxy_configs_file_name proxy_configs_content_type proxy_configs_file_size
                            proxy_configs_updated_at proxy_configs_conf_file_name proxy_configs_conf_content_type
                            proxy_configs_conf_file_size proxy_configs_conf_updated_at]

  # need to reset column information to clear column_names and such
  reset_column_information

  # it has to be THE FIRST callback after create, so associations get the tenant id
  after_create :update_tenant_id, if: :provider?, prepend: true


  include Fields::Fields
  required_fields_are :org_name
  optional_fields_are :org_legaladdress, :org_legaladdress_cont,
                      :telephone_number, :vat_code, :vat_rate, :fiscal_code,
                      :state_region, :city, :country, :zip,
                      :primary_business, :business_category, :po_number
  internal_fields_are :billing_address

  set_fields_account_source :self
  include Fields::Provider

  include ThreeScale::SpamProtection::Integration::Model
  has_spam_protection

  include MasterMethods

  include Backend::ModelExtensions::Provider
  include Logic::Buyer
  include Logic::PlanChanges::Provider
  include Logic::Contracting::Buyer
  include Logic::Signup::Provider
  include Logic::CMS::Provider
  include Logic::ProviderSignup::Provider
  include Logic::ProviderUpgrade::Provider
  include Logic::RollingUpdates::Provider
  include Logic::Contracting::Provider
  include Logic::ProviderSettings
  include Logic::ProviderConstraints
  include ProviderMethods
  include ServiceDiscovery::AuthenticationProviderSupport

  include BuyerMethods
  include Billing
  include BillingAddress
  include PaymentDetails
  include CreditCard
  include Gateway
  include States
  include ProviderDomains
  include AccountIndex::ForAccount

  self.background_deletion = [
    :users,
    :mail_dispatch_rules,
    [:api_docs_services, { class_name: 'ApiDocs::Service' }],
    :services,
    :contracts,
    :account_plans,
    [:settings, { action: :destroy, class_name: 'Settings', has_many: false }],
    [:payment_detail, { action: :destroy, has_many: false }],
    [:buyer_accounts, { action: :destroy, class_name: 'Account' }],
    [:payment_gateway_setting, { action: :destroy, has_many: false }],
    [:profile, { action: :delete, has_many: false }],
    [:templates, { action: :delete, class_name: 'CMS::Template' }],
    [:sections, { action: :delete, class_name: 'CMS::Section' }],
    [:provided_sections, { action: :delete, class_name: 'CMS::Section' }],
    [:redirects, { action: :delete, class_name: 'CMS::Redirect' }],
    [:files, { action: :delete, class_name: 'CMS::File' }],
    [:builtin_pages, { action: :delete, class_name: 'CMS::BuiltinPage' }],
    [:provided_groups, { action: :delete, class_name: 'CMS::Group' }]
  ].freeze

  #TODO: this needs testing?
  scope :providers, -> { where(provider: true) }

  scope :providers_with_master, -> { where.has { (provider == true) | (master == true) } }
  scope :tenants, -> { providers.not_master }

  #OPTIMIZE: adding master boolean a default to false, then this could be done
  # scope :buyers, :conditions => {:provider => false, :master => false}
  scope :buyers, -> { where(provider: false, buyer: true) }

  scope :not_master, -> { where(master: [false, nil]) }

  audited allow_mass_assignment: true

  # this is done in a callback because we want to do this AFTER the account is deleted
  # otherwise the before_destroy admin check in the user will stop the deletion
  after_destroy :destroy_all_users
  after_destroy :destroy_all_contracts

  include WebHooksHelpers #TODO: make this inclusion more dsl-ish
  fires_human_web_hooks_on_events

  before_validation(on: :create, if: :provider?) { generate_s3_prefix }
  before_validation(on: :create, if: :provider?) { generate_domains }
  before_create :generate_site_access_code

  attr_protected :master, :provider, :buyer, :from_email, :vat_rate, :sample_data, :default_service_id, :s3_prefix,
                 :provider_account_id, :paid_at, :paid, :signs_legal_terms, :tenant_id, :default_account_plan_id,
                 :default_service_id, :domain, :subdomain, :self_subdomain, :self_domain,:audit_ids, :partner,
                 :hosted_proxy_deployed_at

  belongs_to :partner
  has_many :users, inverse_of: :account, dependent: :destroy
  has_many :admin_users, -> { admins }, class_name: 'User', inverse_of: :account

  has_one :admin_user, -> { admins.but_impersonation_admin }, class_name: 'User', inverse_of: :account

  has_many :features, as: :featurable

  composed_of :address,
              mapping: ThreeScale::Address.account_mapping,
              class_name: 'ThreeScale::Address'

  before_destroy :destroy_features

  scope :free, ->(free_date) { where.has { not_exists Contract.have_paid_on(free_date).by_account(BabySqueel[:accounts].id).select(:id) } }

  scope :lacks_cinstance_with_plan_system_name, ->(system_names) {
    where.has do
      not_exists Cinstance.by_account(BabySqueel[:accounts].id).by_plan_system_name(system_names).select(:id)
    end
  }

  alias deleted? scheduled_for_deletion?

  def destroy_features
    features.destroy_all
  end

  def destroy_all_contracts
    contracts.reload.destroy_all
  end

  def smart_destroy
    return if master?
    if buyer?
      first_admin # needs to be cached before destroying
      destroy
    else
      schedule_for_deletion
    end
  end

  def schedule_backend_sync_worker
    BackendProviderSyncWorker.enqueue(id) if provider?
  end

  has_many :messages, -> { visible }, foreign_key: :sender_id, class_name: 'Message'
  has_many :sent_messages, foreign_key: :sender_id, class_name: 'Message'

  has_many :mail_dispatch_rules, dependent: :destroy
  has_many :system_operations, through: :mail_dispatch_rules

  has_many :hidden_messages, -> { latest_first.received.hidden }, as: :receiver, class_name: 'MessageRecipient'
  has_many :received_messages, -> { latest_first.received.visible }, as: :receiver, class_name: 'MessageRecipient'

  has_many :api_docs_services, class_name: 'ApiDocs::Service', dependent: :destroy
  has_many :log_entries, foreign_key: 'provider_id'

  has_many :events, class_name: 'EventStore::Event', foreign_key: :provider_id, inverse_of: :account
  has_many :access_tokens, through: :users
  has_many :sso_authorizations, through: :users
  has_many :user_sessions, through: :users

  alias_attribute :name, :org_name

  has_one :onboarding

  def trashed_messages
    Message.where('id IN (:sent) OR id IN (:received)',       sent:     sent_messages.hidden.select(:id),
                                                              received: hidden_messages.pluck(:message_id))
  end

  def onboarding
    super || Onboarding.null
  end

  def admins
    users.admins.but_impersonation_admin
  end

  def first_admin
    @_first_admin ||= admins.first
  end

  def first_admin!
    @_first_admin ||= admins.first!
  end

  def has_impersonation_admin?
    provider? && find_impersonation_admin
  end

  def find_impersonation_admin
    users.admins.find_by(username: ThreeScale.config.impersonation_admin['username'])
  end

  # Users of this account + users of all buyer accounts of this account (if it is provider).
  def managed_users
    conditions = ['users.account_id = :id OR accounts.provider_account_id = :id', { id: id }]
    User.where(conditions).joins(:account).readonly(false)
  end

  def forum!
    forum || raise(ActiveRecord::RecordNotFound, "buyer accounts can't have forum")
  end

  def build_forum(attributes = {})
    self.forum = Forum.new(attributes.reverse_merge(name: 'Forum'))
  end

  def create_forum(attributes = {})
    build_forum(attributes).tap(&:save)
  end

  #TODO: check if the comment below still holds
  # profile is using acts_as_audited and it will not work if :dependent => :destroy
  has_one :profile, dependent: :delete
  has_one :settings, dependent: :destroy, inverse_of: :account, autosave: true
  lazy_initialization_for :profile, :settings, if: :should_not_be_deleted?
  accepts_nested_attributes_for :profile

  belongs_to :country

  #TODO: test this one
  def bought?(plan)
    contracts.map(&:plan).include?(plan)
  end

  has_many :invitations

  # XXX: This is hax is needed because of current cancan limitation.
  #
  # Basically, to allow cancan tests like this:
  #
  #   can? :create, provider => Account
  #
  # there has to be method :account on the account, which return the provider account.
  #
  # TODO: Patch cancan to support parents with different names than it's class,
  #         or
  #       Split Account class into three classes: BuyerAccount, ProviderAccount and MasterAccount
  #
  alias account provider_account

  #
  # Searching
  #

  include Account::Search

  #
  # Validations
  #

  # TODO: multitenant. enable it?
  # validates_uniqueness_of :s3_prefix
  validates :org_name, presence: true, length: { maximum: 255 }

  validates :org_legaladdress, :domain, :telephone_number, :site_access_code,
            :billing_address_name, :billing_address_address1, :billing_address_address2, :billing_address_city,
            :billing_address_state, :billing_address_country, :billing_address_zip, :billing_address_phone,
            :org_legaladdress_cont, :city, :state_region, :state, :timezone, :from_email, :primary_business,
            :business_category, :zip, :self_domain, :s3_prefix, :support_email, :finance_support_email,
            :billing_address_first_name, :billing_address_last_name, :po_number, :vat_code, :fiscal_code,
            length: { maximum: 255 }

  validates :extra_fields, :invoice_footnote, :vat_zero_text,
            length: { maximum: 65535 }

  validate :validate_timezone
  validate :master_uniqueness, if: :master?

  include Authentication
  validates :support_email,         format: { with: RE_EMAIL_OK, message: MSG_EMAIL_BAD,
                                              allow_blank: true, unless: :buyer? }
  validates :finance_support_email, format: { with: RE_EMAIL_OK, message: MSG_EMAIL_BAD,
                                              allow_blank: true, unless: :buyer? }
  #
  # Other stuff
  #
  def config
    @config ||= Configuration.new(self)
  end

  scope :created_before, ->(date) { where(['created_at <= ?', date]) }
  scope :created_after,  ->(date) { where(['created_at >= ?', date]) }

  def self.attributes_for_destroy_list
    %w[id org_name state org_legaladdress org_legaladdress_cont city state_region telephone_number vat_code vat_rate extra_fields created_at]
  end

  def self.master
    find_by!(master: true)
  end

  def self.provider
    find_by!(provider: true)
  end

  def self.master?
    exists?(master: true)
  end

  def self.master_id
    Rails.cache.fetch('master_account_id') { master.id }
  end

  def self.master_on_premises
    master if ThreeScale.master_on_premises?
  end

  def country=(country_name)
    self.country_id = if country_name.is_a? Country
                        country_name.id
                      elsif country_name
                        Country.find_by(name: country_name)&.id
                      end
  end

  def special_fields
    [:country]
  end

  # Returns the id corresponding to an account with given api key. This function avoids
  # database lookup if possible (uses cache), so it is super fast.
  def self.id_from_api_key(api_key)
    Rails.cache.fetch("account_ids/#{api_key}") do
      Account.first_by_provider_key!(api_key).id # rubocop:disable Rails/DynamicFindBy
    end
  end

  # TODO: Put the bulk approval back.

  # #OPTIMIZE these bulk methods won't work if an unexisting id is passed!

  # # Calls approve on an array of accounts
  # def self.bulk_approve(ids)
  #   ids.each{|id| self.find(id).approve!}
  # end

  # # Calls reject on an array of accounts
  # def self.bulk_reject(ids)
  #   ids.each{|id| self.find(id).reject!}
  # end

  # def self.to_csv
  # end

  def emails
    admins.map(&:email).compact
  end

  def timezone
    self[:timezone] || 'UTC'
  end

  # Currency associated with this account. Fallbacks to country's
  # currency and further to DEFAULT_CURRENCY.
  #
  def currency
    billing_strategy&.currency || country&.currency || DEFAULT_CURRENCY
  end

  # Tax rate associated with this account. It is taken from it's country of
  # residence.
  def tax_rate
    country&.tax_rate || 0.0
  end

  # Return country name
  def country_name
    country ? country.name : ''
  end

  # Return short description (from profile)
  def short_description
    profile ? profile.oneline_description : ''
  end

  def full_address
    [
      org_legaladdress, org_legaladdress_cont, city, state_region
    ].map(&:presence).compact.join(', ')
  end

  def address_for_invoice
    address.presence || billing_address
  end

  def provider?
    self[:provider] || master?
  end

  def tenant?
    provider && !master?
  end

  # @param [SystemOperation] operation
  def fetch_dispatch_rule(operation)
    MailDispatchRule.fetch_with_retry!(system_operation: operation, account: self) do |m|
      m.dispatch = false if %w[weekly_reports daily_reports new_forum_post].include?(operation.ref)
      m.emails = emails.first
    end
  end

  # @param [SystemOperation] operation
  def dispatch_rule_for(operation)
    rule = fetch_dispatch_rule(operation)

    migration = Notifications::NewNotificationSystemMigration.new(self)

    if migration.enabled?
      dispatch = rule.dispatch
      overridden = rule.dispatch = migration.dispatch?(operation)
      logger.info("Overriding dispatch rule for Account #{id} (#{name}) #{dispatch} => #{overridden} for operation #{operation.ref}")
    end

    rule
  end

  # Is the feature allowed for this account?
  def feature_allowed?(feature)
    if master?
      master_feature_allowed?(feature)
    else
      if has_bought_cinstance?
        #TODO: this only applies now to application plans, move the question to plan instead
        bought_plan.features.exists?(system_name: feature.to_s)
      else
        # TODO: ask steve
        feature.to_sym == :method_tracking
      end
    end
  end

  # Decides if the email sent from this provider should have the viral email footer appended.
  def should_apply_email_engagement_footer?
    return false if master?
    if buyer? && !provider? # no idea what I'm doing.
      provider_account.settings.skip_email_engagement_footer.denied?
    else
      settings.skip_email_engagement_footer.denied?
    end
  end

  def reload(options = nil)
    # TODO: there is a pattern emerging here. Abstract up!
    @provided_cinstances = nil
    @buyer_attribute_descriptors = nil
    @signup_form_fields = nil
    @_first_admin = nil

    super
  end

  def backend_object
    raise 'backend_object is only for provider accounts' unless provider?

    @backend_object ||= BackendClient::Connection.new.provider(self)
  end

  # TODO: should be multiple_applications_enabled?
  # don't freak out, this is a legacy naming
  def multiple_applications_allowed?
    return false unless settings
    settings.multiple_applications.visible?
  end

  def to_xml(options = {})
    #TODO: use Nokogiri builder
    xml = options[:builder] || ThreeScale::XML::Builder.new

    xml.account do |xml|
      unless new_record?
        xml.id_ id
        xml.created_at created_at.xmlschema
        xml.updated_at updated_at.xmlschema
      end

      xml.state state
      xml.deletion_date deletion_date.xmlschema if scheduled_for_deletion? && deletion_date

      if provider?
        xml.admin_domain admin_domain
        xml.domain domain
        xml.admin_base_url admin_base_url
        xml.base_url base_url
        xml.from_email from_email
        xml.support_email support_email
        xml.finance_support_email finance_support_email
        xml.site_access_code site_access_code
      end

      unless destroyed?
        fields_to_xml(xml)
        extra_fields_to_xml(xml)

        unless should_be_deleted?
          xml.monthly_billing_enabled settings.monthly_billing_enabled
          xml.monthly_charging_enabled settings.monthly_charging_enabled
        end

        xml.credit_card_stored credit_card_stored?

        if credit_card_stored?
          xml.credit_card_partial_number payment_detail.credit_card_partial_number
          xml.credit_card_expires_on payment_detail.credit_card_expires_on
        end

        bought_plans.to_xml(builder: xml, root: 'plans')
        users.to_xml(builder: xml, root: 'users')

        bought_cinstances.to_xml(builder: xml, root: 'applications') if options[:with_apps]
      end
    end

    xml.to_xml
  end

  def generate_s3_prefix
    self.s3_prefix = if org_name
                       org_name.parameterize
                     else
                       # TODO: Add time zone
                       Digest::SHA1.hexdigest(Time.now.to_s)[0..20]
                     end
  end

  def paid?
    contracts.any? { |c| c.paid? }
  end

  def on_trial?
    contracts.all? { |c| c.trial? }
  end

  # Grabs the support_email if defined, otherwise falls back to the email of first admin. Dog.
  def support_email
    se = self[:support_email]
    se.presence || admins.first&.email
  end

  def finance_support_email
    self[:finance_support_email].presence || support_email
  end

  def provider_id_for_audits
    if buyer?
      provider_account&.provider_id_for_audits
    else
      id
    end
  end

  private

  def validate_timezone
    tz = ActiveSupport::TimeZone.new(timezone)

    unless ALLOWED_TIMEZONES.include?(tz)
      errors.add(:timezone, "Timezone #{timezone} is not allowed")
    end
  end

  def master_feature_allowed?(feature)
    # HACK: have to hardcode the features here, because master account is not signed up
    # to any plan, so there is no real list of features for it.
    feature != :anonymous_clients
  end

  def generate_site_access_code
    self.site_access_code ||= SecureRandom.hex(5) if provider?
  end

  def destroy_all_users
    users.each(&:destroy)
  end

  def update_tenant_id
    update_column(:tenant_id, id)
  end

  def master_uniqueness
    scope = self.class.unscoped
    scope = persisted? ? scope.where.not(id: id) : scope

    errors.add :master, 'can be only one' if scope.exists?(master: true)
  end

  protected
end
