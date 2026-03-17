# frozen_string_literal: true

class Settings
  attr_accessor :account
  alias provider account

  # Eager-load all AccountSetting subclasses so we can discover them
  Rails.autoloaders.main.eager_load_dir(Rails.root.join('app/models/account_setting'))

  # Build maps from discovered STI leaf classes
  SETTING_CLASSES = AccountSetting.descendants.select { |klass| klass.descendants.empty? }.freeze

  SETTING_CLASS_MAP = SETTING_CLASSES.each_with_object({}) { |klass, hash| hash[klass.setting_name] = klass }.freeze
  ALL_SETTINGS = SETTING_CLASS_MAP.transform_values(&:default_value).freeze

  # --- Define accessor methods that delegate to AccountSetting records ---

  ALL_SETTINGS.each do |name, default|
    define_method(name) do
      record = setting_record_for(name)
      record ? record.typed_value : default
    end
    define_method("#{name}=") do |value|
      if value.nil?
        clear_setting(name)
      else
        find_or_build_setting(name).typed_assign(value)
      end
    end
  end

  SETTING_CLASSES.select { |k| k < AccountSetting::BooleanSetting }.each do |klass|
    define_method("#{klass.setting_name}?") { !!send(klass.setting_name) }
  end

  include Switches

  # --- Override special attribute accessors ---

  def authentication_strategy
    record = setting_record_for(:authentication_strategy)
    val = record ? record.typed_value : ALL_SETTINGS[:authentication_strategy]
    val ? ActiveSupport::StringInquirer.new(val) : val
  end

  def spam_protection_level
    record = setting_record_for(:spam_protection_level)
    val = record ? record.typed_value : ALL_SETTINGS[:spam_protection_level]
    return :none if val.blank?
    level = val.to_sym
    level == :auto ? :captcha : level
  end

  def admin_bot_protection_level
    record = setting_record_for(:admin_bot_protection_level)
    val = record ? record.typed_value : ALL_SETTINGS[:admin_bot_protection_level]
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
    record.value ||= AccountSetting::BooleanSetting.serialize(ALL_SETTINGS[name])
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

  def self.non_null?(name)
    SETTING_CLASS_MAP[name.to_sym]&.non_null
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

  def setting_record_for(name)
    klass = SETTING_CLASS_MAP[name.to_sym]
    return nil unless klass && account
    sti_name = klass.sti_name
    account.account_settings.find { |r| r.type == sti_name && !r.marked_for_destruction? }
  end

  def find_or_build_setting(name)
    klass = SETTING_CLASS_MAP[name.to_sym]
    return nil unless klass && account
    sti_name = klass.sti_name

    record = account.account_settings.find { |r| r.type == sti_name }
    if record
      record.instance_variable_set(:@marked_for_destruction, false) if record.marked_for_destruction?
      return record
    end

    account.account_settings.build(type: sti_name, tenant_id: account.tenant_id)
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
    attrs.reject { |key, value| self.class.non_null?(key) && value.to_s.empty? }
  end
end
