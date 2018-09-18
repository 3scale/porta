# Use Configuration[:key] to get a global configuration option and
# account.config[:key] to get a per-account configuration.
#
class Configuration

  include Enumerable

  HARDWIRED_DEFAULTS = {
    "allowed_values" => {
      "authentication_strategy" => ["internal", "cas"],
      "backend_version"=> [1, 2]
    },

    "defaults" => {
      "multiple_users" => false, # provider settings
      "advanced_cms" => false, # REMOVE!
      "backend_version" => 2, # service
      "authentication_strategy" => "internal",  # provider settings
      "billing_mode" => false, # provider settings
      "multiple_applications" => false # provider settings
    }
  }

  def initialize(configurable = nil)
    @configurable = configurable
  end

  delegate :each, :to => :values

  def [](name)
    raise "Tried to access deprecated configuration '#{name}'"
  end

  # TODO: remove when all enterprises are migrated (cca 30th of April 2012
  # the latest)
  def fetch_deprecated(name)
    values[name]
  end

  def []=(name, value)
    raise "Tried to set deprecated configuration '#{name}' with '#{value}'"
    values[name] = self.class.parse(value)
  end

  def delete(name)
    values.delete(name)
    values[name] = self.class.defaults[name] if self.class.defaults.has_key?(name)
  end

  def modified?(name)
    values[name] != self.class.defaults[name]
  end

  def boolean?(name)
    [true, false].include?(values[name])
  end

  def enum?(name)
    allowed_values_for(name).present?
  end

  # TODO: test this
  def allowed_values_for(name)
    self.class.allowed_values[name]
  end

  # Set a value and save.
  def set!(name, value)
    # DEPRECATED: added on 24th of February 2012
    # TODO: replace all calls to .config.set!(:multiple_applications, xx)
    # and remove this workaround
    if name.to_sym == :multiple_applications
      settings = @configurable.settings

      # Jewel (tm)
      if value
        settings.allow_multiple_applications! if settings.can_allow_multiple_applications?
        settings.show_multiple_applications!
      else
        settings.deny_multiple_applications! if settings.can_deny_multiple_applications?
      end
    else
      raise "Tried to access deprecated configuration '#{name}'"
    end

    ThreeScale::Warnings.deprecated_method("[#{name}]=(#{value})")
  end

  # Saves modified Values in a transcation. Calls
  # +configuration_changed+ callback on +configurable+ object if it
  # responds to it.
  #
  def save!
    return unless loaded?

    Value.transaction do
      Value.by_configurable(@configurable).delete_all

      modified_values.each do |name, value|
        Value.create!(:configurable => @configurable, :name => name, :value => value.to_s)
      end

      @configurable.configuration_changed if @configurable.respond_to?(:configuration_changed)
    end
  end

  def reload
    @values = nil
  end

  def self.defaults
    @@defaults ||= load_defaults
  end

  def self.reload
    @@current = nil
    @@defaults       = nil
    @@allowed_values = nil
  end

  # TODO: test this
  def self.allowed_values
    @@allowed_values ||= load_allowed_values
  end

  def self.[](name)
    configuration[name.to_s]
  end

  private

  def self.configuration
    @@current ||= HARDWIRED_DEFAULTS
  end

  def values
    @values ||= self.class.defaults.merge(load_values)
  end

  def loaded?
    !@values.nil?
  end

  def load_values
    self.class.preprocess(Value.by_configurable(@configurable).to_hash)
  end

  # Values different from defaults
  def modified_values
    values.dup.delete_if do |name, value|
      self.class.defaults[name] == value
    end
  end

  def self.load_defaults
    preprocess(configuration['defaults'] || {})
  end

  # TODO: test this
  def self.load_allowed_values
    configuration['allowed_values'] || {}
  end

  def self.preprocess(values)
    (values || {}).map_values { |value| parse(value) }.with_indifferent_access
  end

  def self.parse(value)
    if value.respond_to?(:downcase)
      case value.downcase.strip
      when 'true', 'yes'  then true
      when 'false', 'no'  then false
      when /\A[+-]?\d+\Z/ then value.to_i
      when /\A\s*\Z/      then nil
      else value
      end
    else
      value
    end
  end

  class Value < ApplicationRecord
    self.table_name = 'configuration_values'

    # TODO: test!
    belongs_to :configurable, :polymorphic => true

    validates :configurable_type, length: { maximum: 50 }
    validates :name, :value, length: { maximum: 255 }

    symbolize :name

    def self.by_configurable(configurable)
      # TODO: In theory, this should take superclasses into account, but we don't
      # need it yet, so we won't bother.

      where(configurable_id: configurable.id, configurable_type: configurable.class.name)
    end

    def self.to_hash
      all.inject({}.with_indifferent_access) do |memo, record|
        memo[record.name] = record.value
        memo
      end
    end

    def configurable=(record)
      self.configurable_id   = record.id
      self.configurable_type = record.class.name
    end
  end
end
