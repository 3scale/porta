require 'digest/sha1'

class User < ApplicationRecord
  include Symbolize

  include Fields::Fields
  required_fields_are :username, :email
  optional_fields_are :title, :first_name, :last_name, :job_role
  set_fields_account_source :account

  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken

  include CrossDomainSessions
  include Roles
  include States
  include Invitations
  include Permissions
  include ProvidedAccessTokens
  include AccountIndex::ForDependency

  self.background_deletion = [
    :user_sessions,
    :access_tokens,
    [:sso_authorizations, { action: :delete }],
    [:moderatorships, { action: :delete }],
    [:notifications, { action: :delete }],
    [:notification_preferences, { action: :delete, class_name: 'NotificationPreferences', has_many: false }]
  ].freeze

  audited except: %i[salt posts_count janrain_identifier cas_identifier password_digest
                     authentication_id open_id last_login_at last_login_ip crypted_password].freeze

  before_validation :trim_white_space_from_username
  before_destroy :can_be_destroyed?

  include WebHooksHelpers #TODO: make this inclusion more dsl-ish
  fires_human_web_hooks_on_events

  def can_be_destroyed?
    errors.add :base, :last_admin unless destroyable?
    throw :abort unless errors.empty?
  end

  belongs_to :account, :autosave => false, :inverse_of => :users

  # TODO: enable this in rails 3.1 or greater :)
  # has_one :provider_account, :through => :account, :source => :provider_account
  delegate :provider_account, :to => :account, :allow_nil => true

  has_many :posts, -> { latest_first }
  has_many :topics, -> { latest_first }
  has_many :sso_authorizations, dependent: :delete_all

  has_many :moderatorships, :dependent => :delete_all
  has_many :forums, :through => :moderatorships, :source => :forum do
    def moderatable
      select("#{Forum.table_name}.*, #{Moderatorship.table_name}.id as moderatorship_id")
    end
  end

  # TODO: this should be called topic_subscriptions
  has_many :user_topics

  has_many :subscribed_topics, :through => :user_topics, :source => :topic

  has_many :user_sessions, dependent: :destroy

  has_many :notifications, dependent: :delete_all, inverse_of: :user
  has_one  :notification_preferences, dependent: :delete, inverse_of: :user

  has_many :access_tokens, foreign_key: :owner_id, dependent: :destroy, inverse_of: :owner

  symbolize :signup_type

  validates :username, length: { :within => 3..40, :allow_blank => false }
  validates :username, format: { :with => RE_LOGIN_OK, :allow_blank => true,
                                 :message => MSG_LOGIN_BAD }

  #OPTIMIZE: use the same format validations in user, account and invitation, add TESTS!
  validates :email, length: { :within => 6..255, :allow_blank => true } #r@a.wk
  validates :email, format: { :with => RE_EMAIL_OK, :allow_blank => false,
                              :message => MSG_EMAIL_BAD, :unless => :minimal_signup? }

  #TODO: this needs tests
  validates :password, length: { :minimum => 6, :allow_blank => true,
                      :if => ->(u){ u.validate_password? and not u.send(:provider_requires_strong_passwords?) } }

  validates :extra_fields, length: { maximum: 65535 }
  validates :crypted_password, :salt, :remember_token, :activation_code,
            length: { maximum: 40 }
  validates :state, :role, :lost_password_token, :first_name, :last_name, :signup_type,
            :job_role, :last_login_ip, :email_verification_code, :title, :cas_identifier,
            :authentication_id, :open_id, :password_digest,
            length: { maximum: 255 }

  # strong passwords
  special_characters = '-+=><_$#.:;!?@&*()~][}{|'
  RE_STRONG_PASSWORD = %r{
    \A
      (?=.*\d) # number
      (?=.*[a-z]) # lowercase
      (?=.*[A-Z]) # uppercase
      (?=.*[#{Regexp.escape(special_characters)}]) # special char
      (?!.*\s) # does not end with space
      .{8,} # at least 8 characters
    \z
  }x

  STRONG_PASSWORD_FAIL_MSG = "Password must be at least 8 characters long, and contain both upper and lowercase letters, a digit and one special character of #{special_characters}."
  validates :password, format: { :with => RE_STRONG_PASSWORD, :message => STRONG_PASSWORD_FAIL_MSG,
                                 :if => :provider_requires_strong_passwords? }

  validates :conditions, acceptance: { :on => :create }
  validates :service_conditions, acceptance: { :on => :create }

  validate :email_is_unique
  validate :username_is_unique
  validates :open_id, uniqueness: true, allow_nil: true

  attr_accessible :title, :username, :email, :first_name, :last_name, :password,
                  :password_confirmation, :conditions, :cas_identifier, :open_id,
                  :service_conditions, :job_role, :extra_fields, as: %i[default member admin]

  attr_accessible :member_permission_service_ids, :member_permission_ids, as: %i[admin]

  # after_validation :reset_lost_password_token

  after_save :nullify_authentication_id, if: :any_sso_authorizations?
  after_destroy :archive_as_deleted

  alias account_for_sphinx account
  protected :account_for_sphinx

  def self.search_states
    %w(pending active)
  end

  scope :without_ids, ->(id) { id ? where(['users.id <> ?', id]) : where({}) }

  scope :by_email, ->(email) { where(:email => email) }

  scope :latest, -> {limit(5).order(created_at: :desc)}

  scope :but_impersonation_admin, -> { where(['username <> ?', ThreeScale.config.impersonation_admin['username']]) }
  scope :impersonation_admins, -> { where(username: ThreeScale.config.impersonation_admin['username']) }

  scope :admins, -> { where(role: 'admin') }

  scope :active, -> { where(state: 'active') }
  scope :with_valid_password_token, -> { where { lost_password_token_generated_at >= 24.hours.ago } }

  def self.find_by_username_or_email(value)
    find_by(['users.username = ? OR users.email = ?', value, value])
  rescue TypeError
    nil
  end

  def self.find_with_valid_password_token(token)
    with_valid_password_token.find_by(lost_password_token: token)
  end

  def self.impersonation_admin!
    impersonation_admins.first!
  end

  def self.impersonation_admin
    impersonation_admins.first
  end

  def impersonation_admin?
    username == ThreeScale.config.impersonation_admin['username']
  end

  def any_sso_authorizations?
    persisted? ? sso_authorizations.exists? : sso_authorizations.any?
  end

  def notification_preferences
    migration = Notifications::NewNotificationSystemMigration.new(account)

    super || build_notification_preferences(preferences: migration.notification_preferences)
  end

  def accessible_services
    account.accessible_services.permitted_for(self)
  end

  def multiple_accessible_services?
    account.multiple_accessible_services?(Service.permitted_for(self))
  end

  def accessible_services?
    accessible_services.exists?
  end

  delegate :accessible_backend_apis, to: :account

  def allowed_access_token_scopes
    AccessToken.scopes.allowed_for(self)
  end

  def accessible_service_tokens
    if has_permission?(:plans)
      accessible_services.joins(:service_tokens)
        .includes(:service_tokens).map(&:active_service_token)
    else
      []
    end
  end

  def accessible_cinstances
    account.provided_cinstances.permitted_for(self)

    # TODO: this has no clear migration path
    # once we would enable the :service_permissions feature for everyone
    # members that have no access to service would stop seeing applications
  end

  def accessible_service_contracts
    account.provided_service_contracts.permitted_for(self)
  end

  def can_login?
    # Only buyers need to be approved for now.
    (active? || email_unverified?) && account && (account.provider? || account.approved?)
  end

  def expire_password_token
    update_columns(lost_password_token_generated_at: nil)
  end

  def generate_lost_password_token
    attributes = {
      lost_password_token: token = SecureRandom.hex(32),
      lost_password_token_generated_at: Time.current
    }
    assign_attributes(attributes, without_protection: true)

    token if save(validate: true)
  end

  def generate_lost_password_token!
    if generate_lost_password_token
      if account.provider?
        ProviderUserMailer.lost_password(self).deliver_now
      else
        UserMailer.lost_password(self).deliver_now
      end
    end
  end

  def update_password(new_password, new_password_confirmation)
    self.password              = new_password
    self.password_confirmation = new_password_confirmation
    reset_lost_password_token if valid?
    save
  end

  def using_password?
    password_digest.present? || crypted_password.present?
  end

  def can_set_password?
    account.password_login_allowed? && !using_password?
  end

  def kill_user_sessions( but = UserSession.new)
    sessions_to_destroy = user_sessions
    sessions_to_destroy = sessions_to_destroy.where.not(id: but.id) if but.persisted?

    # Destroy all would try to load 25k objects to memory
    sessions_to_destroy.delete_all
  end

  def signup
    @_signup ||= SignupType.new(self)
  end

  def new_signup?
    signup.new?
  end

  def minimal_signup?
    signup.minimal?
  end

  def api_signup?
    signup.api?
  end

  def cas_signup?
    signup.cas?
  end

  def open_id_signup?
    signup.open_id?
  end

  def created_by_provider_signup?
    signup.created_by_provider?
  end

  def password_required?
    signup.by_user? && super
  end

  def recently_activated?
    !minimal_signup? && super
  end

  # CMS Methods patched below - to be moved to module, or gem to be adjusted directly

  def self.current
    Thread.current[:cms_user]
  end

  def self.tenant_id
    current.try!(:tenant_id)
  end

  def self.current=(user)
    Thread.current[:cms_user] = user
  end

  def self.attributes_for_destroy_list
    %w( id account_id username email first_name last_name role job_role extra_fields state activated_at created_at)
  end

  def make_activation_code
    self.activation_code = self.class.make_token
  end

  #NEW CMS END

  def toggle_suspend
    if self.suspended?
      self.unsuspend!
    else
      self.suspend!
    end
  end

  def account_approved?
    account && account.approved? || false
  end

  def update_last_login!(options)
    options.assert_valid_keys(:time, :ip)

    self.last_login_at = options[:time]
    self.last_login_ip = options[:ip]

    # do not call callbacks
    self.class.where(id: id).update_all(last_login_at: options[:time], last_login_ip: options[:ip])
  end

  def subscribed?(topic)
    self.subscribed_topics.include? topic
  end

  def to_xml(options = {})
    xml = options[:builder] || ThreeScale::XML::Builder.new

    xml.user do |xml|
      unless new_record?
        xml.id_ id
        xml.created_at created_at.xmlschema
        xml.updated_at updated_at.xmlschema
      end

      xml.account_id self.account_id
      xml.state state

      xml.role role.to_s

      xml.cas_identifier(cas_identifier) if cas_signup?
      xml.open_id open_id if open_id_signup?

      unless destroyed?
        fields_to_xml(xml)
        extra_fields_to_xml(xml)
      end
    end

    xml.to_xml
  end

  def special_fields
    [:password, :password_confirmation]
  end

  #TODO: do this with an association
  def sections
    account.accessible_sections if account
  end

  def validate_password?
    password_required? && password_changed?
  end

  def unique?(attribute)
    unique_in?(uniqueness_scope, attribute)
  end

  def unique_in?(scope, attribute)
    scope ||= self.class
    condition = uniqueness_condition_for(attribute)
    not scope.without_ids(self.id).exists?(condition)
  end

  def provider_id_for_audits
    account.try!(:provider_id_for_audits) || provider_account.try!(:provider_id_for_audits)
  end

  private

  def archive_as_deleted
    return unless Features::SegmentDeletionConfig.enabled?
    tenant_or_master = account.tenant? ? account : provider_account
    ::DeletedObject.create!(object: self, owner: tenant_or_master)
  end

  def destroyable?
    return true if destroyed_by_association
    !(account && !account.destroyed? && account.admins == [self])
  end

  def nullify_authentication_id
    update_column(:authentication_id, nil)
  end

  def provider_requires_strong_passwords?
    # use fields definitons source (instance variable) as backup when creating new record
    # and there is no provider account (its still new record and not set through association.build)
    if validate_password? && (source = fields_definitions_source_root)
      source.settings.strong_passwords_enabled?
    end
  end

  def trim_white_space_from_username
    self.username= self.username.strip if self.username
  end

  def reset_lost_password_token
    self.lost_password_token = nil
  end

  def uniqueness_condition_for(attribute)
    { attribute => self[attribute] }
  end

  def uniqueness_scope
    case
    when account.try!(:provider?)
      account.users

    when provider = account.try!(:provider_account) # buyers
      provider.buyer_users

    end
  end

  def email_is_unique
    errors.add(:email, :taken) if email.present? && (not unique?(:email))
  end

  def username_is_unique
    errors.add(:username, :taken) if username.present? && (not unique?(:username))
  end

  class << self
    def find_ids(options)
      sql = construct_finder_sql(options)
      self.connection.select_values(sql)
    end
  end

  class SignupType
    def initialize(user)
      @user = user
    end

    def partner?
      signup_type.to_s.match(/^partner(:|$)/)
    end

    def new?
      signup_type == :new_signup
    end

    def minimal?
      signup_type == :minimal
    end

    def api?
      signup_type == :api
    end

    def open_id?
      @user.open_id.present?
    end

    def oauth2?
      @user.any_sso_authorizations? || @user.authentication_id.present?
    end

    def created_by_provider?
      signup_type == :created_by_provider
    end

    def cas?
      @user.cas_identifier.present?
    end

    def machine?
      minimal? || api? || created_by_provider? || open_id? || cas? || oauth2?
    end

    def by_user?
      not machine?
    end

    private

    delegate :signup_type, to: :@user
  end

end
