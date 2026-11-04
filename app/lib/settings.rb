# frozen_string_literal: true

class Settings
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_reader :account
  alias provider account

  def persisted?
    !!account&.persisted?
  end

  # Eager-load all AccountSetting subclasses so we can discover them
  Rails.autoloaders.main.eager_load_dir(Rails.root.join('app/models/account_setting'))

  # Build maps from discovered STI leaf classes
  SETTING_CLASSES = AccountSetting.descendants.select { |klass| klass.descendants.empty? }.freeze
  SWITCH_CLASSES, VALUE_CLASSES = SETTING_CLASSES.partition { |k| k < AccountSetting::SwitchSetting }.map(&:freeze)

  SETTING_CLASS_MAP = SETTING_CLASSES.each_with_object({}) { |klass, hash| hash[klass.setting_name.to_sym] = klass }.freeze
  ALL_SETTINGS = SETTING_CLASS_MAP.transform_values(&:default_value).freeze

  # --- Define accessor methods that delegate to AccountSetting records ---

  VALUE_CLASSES.each do |klass|
    name = klass.setting_name
    define_method(name) do
      record = setting_record_for(name)
      record && !record.marked_for_destruction? ? record.value : klass.default_value
    end
    define_method("#{name}=") do |value|
      if value.nil?
        clear_setting(name)
      else
        find_or_build_setting(name).value = value
      end
    end
  end

  SETTING_CLASSES.select { |k| k < AccountSetting::BooleanSetting }.each do |klass|
    define_method("#{klass.setting_name}?") { !!send(klass.setting_name) }
  end

  include Switches

  # --- Override special attribute accessors ---

  def sso_key
    return nil unless account&.persisted? && account.provider?

    record = setting_record_for(:sso_key)
    return record.value if record

    # Lazily generate and persist the SSO key on first access (outside any
    # account creation transaction to avoid FK-induced deadlocks)
    generated = ThreeScale::SSO.generate_sso_key
    AccountSetting.connection.execute(
      AccountSetting.sanitize_sql([
        "INSERT INTO account_settings (account_id, type, value, tenant_id, created_at, updated_at)" \
        " VALUES (?, 'SSOKey', ?, ?, ?, ?)" \
        " ON DUPLICATE KEY UPDATE account_settings.updated_at = account_settings.updated_at",
        account.id, generated, account.tenant_id, Time.current, Time.current
      ])
    )

    persisted_record = AccountSetting::SSOKey.find_by!(account_id: account.id)
    account.account_settings.target&.delete_if { _1.type == 'SSOKey' }
    account.account_settings << persisted_record
    persisted_record.value
  end

  def authentication_strategy
    record = setting_record_for(:authentication_strategy)
    val = record && !record.marked_for_destruction? ? record.value : ALL_SETTINGS[:authentication_strategy]
    val ? ActiveSupport::StringInquirer.new(val) : val
  end

  def spam_protection_level
    record = setting_record_for(:spam_protection_level)
    val = record && !record.marked_for_destruction? ? record.value : ALL_SETTINGS[:spam_protection_level]
    return :none if val.blank?
    level = val.to_sym
    level == :auto ? :captcha : level
  end

  def admin_bot_protection_level
    record = setting_record_for(:admin_bot_protection_level)
    val = record && !record.marked_for_destruction? ? record.value : ALL_SETTINGS[:admin_bot_protection_level]
    val.present? ? val.to_sym : :none
  end

  # --- Initialization ---

  def initialize(account = nil)
    @account = account
  end

  # --- Persistence ---

  def save
    return false unless account&.persisted?
    results = nil
    AccountSetting.transaction do
      results = account.account_settings.map do |record|
        if record.marked_for_destruction?
          record.destroy
        elsif record.new_record? && record.value.nil?
          true
        elsif record.changed? || record.new_record?
          record.save
        else
          true
        end
      end
      account.account_settings.target&.reject!(&:destroyed?)
      raise ActiveRecord::Rollback unless results.all?
    end
    results.all?
  end

  def save!
    return true if save

    record = account_settings.detect { _1.errors.any? }
    raise ActiveRecord::RecordInvalid.new(record) if record

    raise ActiveRecord::RecordNotSaved.new("Failed to save settings", self)
  end

  def update(attrs)
    attrs = normalize_attrs(attrs)
    assign_attributes(attrs)
    save
  end

  def update!(attrs)
    attrs = normalize_attrs(attrs)
    assign_attributes(attrs)
    save!
  end

  def update_attribute(name, value)
    if value.nil?
      clear_setting(name, destroy: true)
    else
      send("#{name}=", value)
      setting_record_for(name)&.save(validate: false)
    end
  end

  def toggle!(name)
    name = name.to_sym
    record = find_or_build_setting(name)
    record.value ||= AccountSetting::BooleanSetting.serialize(ALL_SETTINGS[name])
    record.toggle_value!
  end

  def assign_attributes(attrs)
    normalize_attrs(attrs).each do |key, value|
      send("#{key}=", value) if respond_to?("#{key}=", true)
    end
  end
  alias attributes= assign_attributes

  def errors
    errors = ActiveModel::Errors.new(self)
    account_settings.each do |record|
      record.errors.each do |error|
        errors.add(record.class.setting_name.to_sym, error.message)
      end
    end
    errors
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

  # Read-only delegation to the default account plan — not a stored setting.
  # Controllers that allow this parameter must handle it explicitly before
  # calling settings.update; the facade has no write path for it.
  def account_approval_required
    default_account_plan.approval_required
  end

  delegate :provider_id_for_audits, to: :account, allow_nil: true

  private

  def account_settings
    return [] unless account

    account.account_settings.reject(&:destroyed?)
  end

  def setting_record_for(name)
    klass = SETTING_CLASS_MAP[name.to_sym]
    return nil unless klass

    account_settings.find { _1.type == klass.sti_name }
  end

  def find_or_build_setting(name)
    klass = SETTING_CLASS_MAP[name.to_sym]
    return nil unless klass && account

    sti_name = klass.sti_name
    record = account_settings.find { _1.type == sti_name }
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

  def clear_setting(name, destroy: false)
    record = setting_record_for(name)
    return unless record

    if record.new_record?
      account.account_settings.delete(record)
    elsif destroy
      record.destroy
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

end
