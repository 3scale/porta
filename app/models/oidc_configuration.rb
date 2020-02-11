# frozen_string_literal: true

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
      standard_flow_enabled
      implicit_flow_enabled
      service_accounts_enabled
      direct_access_grants_enabled
    ].freeze

    BOOLEAN_ATTRIBUTES = FLOWS

    ATTRIBUTES = BOOLEAN_ATTRIBUTES
    attr_accessor(*ATTRIBUTES)

    # Defining accessor for boolean to always store `true` or `false`
    BOOLEAN_ATTRIBUTES.each do |attr|
      define_method "#{attr}=" do |value|
        # Always set to `true` or `false`
        # TODO: Rails 5.0 `#type_cast_from_database` will be replaced by `#cast`
        instance_variable_set :"@#{attr}", !!ActiveModel::Type::Boolean.new.deserialize(value) #rubocop:disable Style/DoubleNegation
      end
    end

    def initialize(attributes = {})
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
    alias attributes= assign_attributes

    def attributes
      ATTRIBUTES.each_with_object(ActiveSupport::HashWithIndifferentAccess.new) do |attr, object|
        object[attr] = public_send(attr)
      end
    end
  end

  belongs_to :oidc_configurable, polymorphic: true
  serialize :config, OIDCConfiguration::Config

  delegate(*OIDCConfiguration::Config::ATTRIBUTES, to: :config)
  delegate(*OIDCConfiguration::Config::ATTRIBUTES.map {|attr| "#{attr}=" }, to: :config)

  # Always initialize a valid `config`
  after_initialize :config

  # This would really be better with a XML representer
  def to_xml(options={})
    result = options[:builder] || ThreeScale::XML::Builder.new
    result.oidc_configuration do |xml|
      xml.id id
      Config::ATTRIBUTES.each do |attr|
        xml.tag!(attr, public_send(attr))
      end
    end
    result.to_xml
  end


  private

  def read_attribute_for_serialization(name)
    if name.to_s == 'config'
      config.attributes
    else
      super
    end
  end
end
