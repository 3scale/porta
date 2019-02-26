class OIDCConfiguration < ApplicationRecord
  class Config < ActiveRecord::Coders::JSON
    include ActiveModel::Serialization

    def self.load(string)
      new(super || {})
    end

    def self.dump(record)
      super(record.attributes)
    end

    FLOWS = %i[
      service_accounts_enabled standard_flow_enabled
      implicit_flow_enabled direct_access_grants_enabled
    ].freeze

    BOOLEAN_ATTRIBUTES = FLOWS

    ATTRIBUTES = BOOLEAN_ATTRIBUTES
    attr_accessor *ATTRIBUTES

    # Defining accessor for boolean to always store `true` or `false`
    BOOLEAN_ATTRIBUTES.each do |attr|
      define_method "#{attr}=" do |value|
        # Always set to `true` or `false`
        # TODO: Rails 5.0 `#type_cast_from_database` will be replaced by `#cast`
        instance_variable_set :"@#{attr}", !!ActiveRecord::Type::Boolean.new.type_cast_from_database(value)
      end
    end

    def initialize(attributes={})
      assign_attributes(attributes)
    end

    # TODO: Rails 5. This would be much better with ActiveModel::AttributeAssignment
    # Correctly assign attributes by removing those that are not valid.
    # FIXME: Probably better to raise a NoMethodError?
    def assign_attributes(attrs)
      attributes = ActiveSupport::HashWithIndifferentAccess.new.merge attrs
      ATTRIBUTES.each do |attr|
        public_send "#{attr}=", attributes[attr]
      end
    end
    alias_method :attributes=, :assign_attributes

    def attributes
      ATTRIBUTES.each_with_object(ActiveSupport::HashWithIndifferentAccess.new) do |attr, object|
        object[attr] = public_send(attr)
      end
    end
  end

  belongs_to :oidc_configurable, polymorphic: true
  serialize :config, OIDCConfiguration::Config

  delegate *OIDCConfiguration::Config::ATTRIBUTES, to: :config
  delegate *OIDCConfiguration::Config::ATTRIBUTES.map{|attr| "#{attr}=" }, to: :config

  # Always initialize a valid `config`
  after_initialize :config

  private

  def read_attribute_for_serialization(name)
    if name.to_s == 'config'
      config.attributes
    else
      super
    end
  end
end
