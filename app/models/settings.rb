# frozen_string_literal: true

class Settings
  include ActiveModel::Validations

  attr_accessor :account
  alias provider account

  BOOLEAN_SETTINGS = {
    forum_enabled: true,
    app_gallery_enabled: false,
    anonymous_posts_enabled: false,
    signups_enabled: true,
    documentation_enabled: true,
    useraccountarea_enabled: true,
    documentation_public: true,
    forum_public: true,
    hide_service: nil,
    monthly_charging_enabled: true,
    monthly_billing_enabled: true,
    strong_passwords_enabled: false,
    can_create_service: false,
    public_search: false,
    account_plans_ui_visible: false,
    service_plans_ui_visible: false,
    setup_fee_enabled: false,
    cms_escape_draft_html: true,
    cms_escape_published_html: true,
    enforce_sso: false
  }.freeze

  STRING_SETTINGS = {
    bg_colour: nil,
    link_colour: nil,
    text_colour: nil,
    menu_bg_colour: nil,
    menu_link_colour: nil,
    content_bg_colour: nil,
    plans_tab_bg_colour: nil,
    plans_bg_colour: nil,
    content_border_colour: nil,
    link_label: nil,
    link_url: nil,
    favicon: nil,
    token_api: "default",
    cms_token: nil,
    cc_terms_path: "/termsofservice",
    cc_privacy_path: "/privacypolicy",
    cc_refunds_path: "/refundpolicy",
    change_account_plan_permission: "request",
    change_service_plan_permission: "request",
    authentication_strategy: "oauth2",
    janrain_api_key: nil,
    janrain_relying_party: nil,
    cas_server_url: nil,
    sso_key: nil,
    sso_login_url: nil,
    spam_protection_level: "none",
    admin_bot_protection_level: "none",
    product: "connect",
    tracker_code: nil
  }.freeze

  TEXT_SETTINGS = {
    welcome_text: nil,
    refund_policy: nil,
    privacy_policy: nil
  }.freeze

  SWITCH_SETTINGS = {
    account_plans_switch: "denied",
    service_plans_switch: "denied",
    finance_switch: "denied",
    require_cc_on_signup_switch: "denied",
    multiple_services_switch: "denied",
    multiple_applications_switch: "denied",
    multiple_users_switch: "denied",
    skip_email_engagement_footer_switch: "denied",
    groups_switch: "denied",
    branding_switch: "denied",
    web_hooks_switch: "denied",
    iam_tools_switch: "denied"
  }.freeze

  ALL_SETTINGS = {}.merge(BOOLEAN_SETTINGS, STRING_SETTINGS, TEXT_SETTINGS, SWITCH_SETTINGS).freeze

  # Settings that should reject empty/nil assignment (were NOT NULL in old schema)
  NON_NULL_SETTINGS = %w[
    documentation_public forum_public monthly_billing_enabled can_create_service
    public_search cms_escape_draft_html cms_escape_published_html enforce_sso
    change_account_plan_permission change_service_plan_permission
    authentication_strategy spam_protection_level product
    account_plans_switch service_plans_switch finance_switch
    require_cc_on_signup_switch multiple_services_switch multiple_applications_switch
    multiple_users_switch skip_email_engagement_footer_switch groups_switch
    branding_switch web_hooks_switch iam_tools_switch
  ].freeze

  SETTING_CLASS_MAP = ALL_SETTINGS.each_with_object({}) do |(name, _), hash|
    hash[name] = "AccountSetting::#{name.to_s.camelize}"
  end.freeze

  # --- Validations (same as original) ---

  validates :product, inclusion: { in: %w[connect enterprise].freeze }
  validates :change_account_plan_permission, :change_service_plan_permission,
            inclusion: { in: %w[request none credit_card request_credit_card direct].freeze }
  validates :bg_colour, :link_colour, :text_colour, :menu_bg_colour, :link_label, :link_url, :menu_link_colour, :token_api,
            :content_bg_colour, :tracker_code, :favicon, :plans_tab_bg_colour, :plans_bg_colour, :content_border_colour,
            :cc_privacy_path, :cc_terms_path, :cc_refunds_path, :change_service_plan_permission, :spam_protection_level,
            :authentication_strategy, :janrain_api_key, :janrain_relying_party, :cas_server_url, :sso_key,
            :admin_bot_protection_level, :sso_login_url, length: { maximum: 255 }

  # --- Define accessor methods for non-switch settings ---

  BOOLEAN_SETTINGS.each_key do |name|
    define_method(name) { ensure_loaded; @attributes[name] }
    define_method("#{name}?") { ensure_loaded; !!@attributes[name] }
    define_method("#{name}=") do |value|
      ensure_loaded
      casted = ActiveModel::Type::Boolean.new.cast(value)
      track_change(name, @attributes[name], casted)
      @attributes[name] = casted
    end
  end

  STRING_SETTINGS.each_key do |name|
    define_method(name) { ensure_loaded; @attributes[name] }
    define_method("#{name}=") do |value|
      ensure_loaded
      casted = value.nil? ? nil : value.to_s
      track_change(name, @attributes[name], casted)
      @attributes[name] = casted
    end
  end

  TEXT_SETTINGS.each_key do |name|
    define_method(name) { ensure_loaded; @attributes[name] }
    define_method("#{name}=") do |value|
      ensure_loaded
      casted = value.nil? ? nil : value.to_s
      track_change(name, @attributes[name], casted)
      @attributes[name] = casted
    end
  end

  # --- Define accessor methods for switch settings (needed before include Switches) ---

  SWITCH_SETTINGS.each_key do |attr_name|
    define_method(attr_name) do
      ensure_loaded
      @attributes[attr_name]
    end
    define_method("#{attr_name}=") do |value|
      ensure_loaded
      new_val = value.to_s
      track_change(attr_name, @attributes[attr_name], new_val)
      @attributes[attr_name] = new_val
    end
  end

  # --- Include Switches (state machines) ---

  include Switches

  # --- Override special attribute accessors ---

  # authentication_strategy returns a StringInquirer
  def authentication_strategy
    val = @attributes[:authentication_strategy]
    val ? ActiveSupport::StringInquirer.new(val) : val
  end

  # spam_protection_level returns a symbol; :auto → :captcha
  def spam_protection_level
    val = @attributes[:spam_protection_level]
    return :none if val.blank?
    level = val.to_sym
    level == :auto ? :captcha : level
  end

  # admin_bot_protection_level returns a symbol; default :none
  def admin_bot_protection_level
    val = @attributes[:admin_bot_protection_level]
    val.present? ? val.to_sym : :none
  end

  # --- Initialization ---

  def initialize(account = nil)
    @account = account
    @changes = {}
    @previous_changes = {}
    @new_settings = false
    ensure_loaded
    @changes = {}
  end

  def self.for_account(account)
    settings = new(account)
    if account.persisted? && settings.instance_variable_get(:@new_settings)
      settings.send(:run_initialization_callbacks)
    end
    settings
  end

  def self.defaults
    @defaults ||= ALL_SETTINGS.dup
  end

  # --- Persistence ---

  def save
    return false unless valid?
    @previous_changes = @changes.dup
    persist_changes!
    @changes = {}
    true
  end

  def save!
    save || raise(ActiveModel::ValidationError.new(self))
  end

  def update(attrs)
    attrs = normalize_attrs(attrs)
    update_approval_required(attrs) if approval_required_editable?
    assign_attributes(attrs)
    save
  end

  def update!(attrs)
    attrs = normalize_attrs(attrs)
    update_approval_required(attrs) if approval_required_editable?
    assign_attributes(attrs)
    save!
  end

  def update_attribute(name, value)
    send("#{name}=", value)
    persist_attribute!(name.to_sym)
    true
  end

  def toggle!(name)
    name = name.to_sym
    klass = SETTING_CLASS_MAP[name].constantize
    record = klass.find_or_initialize_by(account: account)
    record.tenant_id = account.tenant_id
    record.value ||= AccountSetting::BooleanSetting.serialize(BOOLEAN_SETTINGS[name])
    new_value = record.toggle_value!
    @attributes[name] = new_value
    new_value
  end

  def assign_attributes(attrs)
    sanitize_attributes(normalize_attrs(attrs)).each do |key, value|
      send("#{key}=", value) if respond_to?("#{key}=", true)
    end
  end
  alias attributes= assign_attributes

  def persist_switch_setting!(switch_name)
    attr_name = :"#{switch_name}_switch"
    persist_attribute!(attr_name)
  end

  # Read a setting value directly from the attributes hash,
  # bypassing any method overrides (e.g. switch methods).
  def read_setting(name)
    ensure_loaded
    name = name.to_sym
    @attributes[name] if ALL_SETTINGS.key?(name)
  end

  def changes
    @changes.dup
  end

  def previous_changes
    @previous_changes.dup
  end

  def updated_at
    account&.account_settings&.maximum(:updated_at)
  end

  def reset
    @attributes = nil
    @changes = {}
    @previous_changes = {}
    @not_custom_account_plans = nil
    self
  end

  def reload
    reset
    account.account_settings.reload if account&.persisted? && account.association(:account_settings).loaded?
    ensure_loaded
    self
  end

  def initialize_copy(source)
    super
    @attributes = source.instance_variable_get(:@attributes)&.dup
    @changes = source.instance_variable_get(:@changes).dup
    @previous_changes = source.instance_variable_get(:@previous_changes).dup
  end

  # --- Class methods ---

  def self.attribute_names
    ALL_SETTINGS.keys.map(&:to_s)
  end

  def self.type_for_attribute(name)
    name = name.to_sym
    if BOOLEAN_SETTINGS.key?(name)
      ActiveModel::Type::Boolean.new
    else
      ActiveModel::Type::String.new
    end
  end

  def self.non_null_columns_names
    NON_NULL_SETTINGS
  end

  def self.setting_class_for(name)
    SETTING_CLASS_MAP[name.to_sym]
  end

  # --- Business logic ---

  def enterprise?
    product == 'enterprise'
  end

  def has_privacy_policy?
    !privacy_policy.blank?
  end

  def has_refund_policy?
    !refund_policy.blank?
  end

  def password_login_allowed?
    true
  end

  def approval_required_editable?
    not_custom_account_plans.size == 1
  end

  def approval_required_disabled?
    not_custom_account_plans.size > 1 && account_plans_ui_visible?
  end

  def account_approval_required
    @account_approval_required = default_account_plan.approval_required
  end

  def account_approval_required=(value)
    @account_approval_required = value
  end

  def generate_sso_key
    self.sso_key = ThreeScale::SSO.generate_sso_key if account && account.provider?
  end

  def set_forum_enabled
    self.forum_public = false if account

    true
  end

  delegate :provider_id_for_audits, to: :account, allow_nil: true

  private

  def track_change(name, old_value, new_value)
    return unless @changes
    if old_value != new_value
      @changes[name] = [old_value, new_value]
    end
  end

  def normalize_attrs(attrs)
    attrs.to_h.symbolize_keys
  end

  def ensure_loaded
    return if @attributes

    @attributes = self.class.defaults.dup
    load_from_account_settings if account&.persisted?
  end

  def load_from_account_settings
    records = account.account_settings
    if records.empty?
      @new_settings = true
      return
    end
    records.each do |record|
      name = setting_name_from_type(record.type)
      next unless name && ALL_SETTINGS.key?(name)
      @attributes[name] = deserialize_value(name, record.value)
    end
  end

  def run_initialization_callbacks
    generate_sso_key
    set_forum_enabled
    save
    @new_settings = false
  end

  def setting_name_from_type(type_name)
    # "AccountSetting::ForumEnabled" → :forum_enabled
    return nil unless type_name&.start_with?("AccountSetting::")
    type_name.sub("AccountSetting::", "").underscore.to_sym
  end

  def deserialize_value(name, raw_value)
    if BOOLEAN_SETTINGS.key?(name)
      ActiveModel::Type::Boolean.new.cast(raw_value)
    else
      raw_value
    end
  end

  def serialize_value(name, value)
    if BOOLEAN_SETTINGS.key?(name)
      value ? "1" : "0"
    else
      value.to_s
    end
  end

  def persist_changes!
    @changes.each_key do |name|
      persist_attribute!(name)
    end
  end

  def persist_attribute!(name)
    return unless account&.persisted?
    value = @attributes[name]
    setting_type = SETTING_CLASS_MAP[name]
    return unless setting_type

    if value.nil?
      account.account_settings.where(type: setting_type).delete_all
    else
      record = account.account_settings.find_or_initialize_by(type: setting_type)
      record.value = serialize_value(name, value)
      record.tenant_id = account.tenant_id
      record.save!
    end
  end

  def not_custom_account_plans
    @not_custom_account_plans ||= provider.account_plans.not_custom
  end

  def default_account_plan
    provider.account_plans.default || not_custom_account_plans.first!
  end

  def update_approval_required(attrs)
    value = attrs.delete(:account_approval_required)
    default_account_plan.update_attribute(:approval_required, value) unless value.to_s.empty?
  end

  def sanitize_attributes(attrs)
    attrs.reject { |key, value| self.class.non_null_columns_names.include?(key.to_s) && value.to_s.empty? }
  end
end
