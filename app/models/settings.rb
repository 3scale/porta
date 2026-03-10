# frozen_string_literal: true

class Settings
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

  # --- Define accessor methods that delegate to AccountSetting records ---

  BOOLEAN_SETTINGS.each_key do |name|
    define_method(name) do
      record = setting_record_for(name)
      record ? record.typed_value : BOOLEAN_SETTINGS[name]
    end
    define_method("#{name}?") { !!send(name) }
    define_method("#{name}=") do |value|
      casted = ActiveModel::Type::Boolean.new.cast(value)
      find_or_build_setting(name).value = AccountSetting::BooleanSetting.serialize(casted)
    end
  end

  STRING_SETTINGS.each_key do |name|
    define_method(name) do
      record = setting_record_for(name)
      record ? record.typed_value : STRING_SETTINGS[name]
    end
    define_method("#{name}=") do |value|
      if value.nil?
        clear_setting(name)
      else
        find_or_build_setting(name).value = value.to_s
      end
    end
  end

  TEXT_SETTINGS.each_key do |name|
    define_method(name) do
      record = setting_record_for(name)
      record ? record.typed_value : TEXT_SETTINGS[name]
    end
    define_method("#{name}=") do |value|
      if value.nil?
        clear_setting(name)
      else
        find_or_build_setting(name).value = value.to_s
      end
    end
  end

  # Switch value getters/setters (e.g., finance_switch returns 'denied')
  SWITCH_SETTINGS.each_key do |attr_name|
    define_method(attr_name) do
      record = setting_record_for(attr_name)
      record&.value || 'denied'
    end
    define_method("#{attr_name}=") do |value|
      find_or_build_setting(attr_name).transition_to(value)
    end
  end

  include Switches

  # --- Override special attribute accessors ---

  def authentication_strategy
    val = setting_value(:authentication_strategy, STRING_SETTINGS)
    val ? ActiveSupport::StringInquirer.new(val) : val
  end

  def spam_protection_level
    val = setting_value(:spam_protection_level, STRING_SETTINGS)
    return :none if val.blank?
    level = val.to_sym
    level == :auto ? :captcha : level
  end

  def admin_bot_protection_level
    val = setting_value(:admin_bot_protection_level, STRING_SETTINGS)
    val.present? ? val.to_sym : :none
  end

  # --- Initialization ---

  def initialize(account = nil)
    @account = account
  end

  def self.defaults
    @defaults ||= ALL_SETTINGS.dup
  end

  # --- Persistence ---

  def save
    save!
    true
  rescue ActiveRecord::RecordInvalid
    false
  end

  def save!
    return unless account&.persisted?
    AccountSetting.transaction do
      account.account_settings.each do |record|
        if record.marked_for_destruction?
          record.destroy!
        elsif record.changed? || record.new_record?
          record.save!
        end
      end
    end
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
    record = setting_record_for(name.to_sym)
    record.save! if record
    true
  end

  def toggle!(name)
    name = name.to_sym
    record = find_or_build_setting(name)
    record.value ||= AccountSetting::BooleanSetting.serialize(BOOLEAN_SETTINGS[name])
    record.toggle_value!
  end

  def assign_attributes(attrs)
    sanitize_attributes(normalize_attrs(attrs)).each do |key, value|
      send("#{key}=", value) if respond_to?("#{key}=", true)
    end
  end
  alias attributes= assign_attributes

  def dirty?
    account&.account_settings&.any? { |r| r.changed? || r.new_record? || r.marked_for_destruction? }
  end

  def updated_at
    account&.account_settings&.maximum(:updated_at)
  end

  def reset
    @not_custom_account_plans = nil
    self
  end

  def reload
    reset
    account.account_settings.reload if account&.persisted?
    self
  end

  # --- Class methods ---

  def self.attribute_names
    ALL_SETTINGS.keys.map(&:to_s)
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

  delegate :provider_id_for_audits, to: :account, allow_nil: true

  private

  def setting_value(name, defaults)
    record = setting_record_for(name)
    record ? record.typed_value : defaults[name]
  end

  def setting_record_for(name)
    type = SETTING_CLASS_MAP[name.to_sym]
    return nil unless type && account
    account.account_settings.find { |r| r.type == type && !r.marked_for_destruction? }
  end

  def find_or_build_setting(name)
    setting_record_for(name) || begin
      type = SETTING_CLASS_MAP[name.to_sym]
      klass = type.constantize
      klass.new(account: account, tenant_id: account.tenant_id).tap do |record|
        account.association(:account_settings).add_to_target(record)
      end
    end
  end

  def find_or_build_switch(name)
    find_or_build_setting(:"#{name}_switch")
  end

  def normalize_attrs(attrs)
    attrs.to_h.symbolize_keys
  end

  def clear_setting(name)
    record = setting_record_for(name)
    return unless record
    if record.new_record?
      account.account_settings.delete(record)
    else
      record.mark_for_destruction
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
