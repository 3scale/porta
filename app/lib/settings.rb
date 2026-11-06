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
  SETTING_CLASSES = AccountSetting.descendants.select { _1.descendants.empty? }.freeze
  SWITCH_CLASSES, VALUE_CLASSES = SETTING_CLASSES.partition { _1 < AccountSetting::SwitchSetting }.map(&:freeze)

  SETTING_CLASS_MAP = SETTING_CLASSES.index_by { _1.setting_name.to_sym }.freeze
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

  SETTING_CLASSES.select { _1 < AccountSetting::BooleanSetting }.each do |klass|
    define_method("#{klass.setting_name}?") { !!send(klass.setting_name) }
  end

  include Switches

  # --- Override special attribute accessors ---

  def sso_key
    return nil unless account&.persisted? && account.provider?

    record = setting_record_for(:sso_key)
    return record.value if record

    persisted_record = account.account_settings.create_or_find_by!(type: AccountSetting::SSOKey.sti_name) do |record|
      record.value = ThreeScale::SSO.generate_sso_key
    end
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

    success = false
    AccountSetting.transaction do
      to_destroy, to_persist = account.account_settings.partition(&:marked_for_destruction?)

      results = to_persist.select(&:changed?).map(&:save)

      raise ActiveRecord::Rollback unless results.all?

      # destroy! is used internally by CollectionProxy#destroy, so failures raise
      # instead of returning false. Acceptable: a destroy failure here means
      # something is seriously broken (no callbacks exist on AccountSetting).
      account.account_settings.destroy(*to_destroy) if to_destroy.any?
      success = true
    end
    success
  end

  def save!
    return true if save

    record = active_settings.detect { _1.errors.any? }
    raise ActiveRecord::RecordInvalid, record if record

    raise ActiveRecord::RecordNotSaved.new("Failed to save settings", self)
  end

  def update(attrs)
    assign_attributes(attrs)
    save
  end

  def update!(attrs)
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
    record.toggle_value!
  end

  def assign_attributes(attrs)
    attrs.to_h.each do |key, value|
      send("#{key}=", value) if respond_to?("#{key}=", true)
    end
  end
  alias attributes= assign_attributes

  def errors
    errors = ActiveModel::Errors.new(self)
    active_settings.each do |record|
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
    privacy_policy.present?
  end

  def has_refund_policy?
    refund_policy.present?
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

  def active_settings
    return [] unless account

    account.account_settings.reject(&:destroyed?)
  end

  def setting_record_for(name)
    klass = SETTING_CLASS_MAP[name.to_sym]
    return nil unless klass

    active_settings.find { _1.type == klass.sti_name }
  end

  def find_or_build_setting(name)
    klass = SETTING_CLASS_MAP[name.to_sym]
    return nil unless klass && account

    sti_name = klass.sti_name
    record = active_settings.find { _1.type == sti_name }
    if record
      record.instance_variable_set(:@marked_for_destruction, false) if record.marked_for_destruction?
      return record
    end

    account.account_settings.build(type: sti_name)
  end

  def find_or_build_switch(name)
    find_or_build_setting(:"#{name}_switch")
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
