# frozen_string_literal: true

# DUCK: This should be either a model by itself or remove the whole thing and live with billing_address_ prefix
module Account::BillingAddress
  extend ActiveSupport::Concern

  class AddressFormatError < StandardError
    attr_reader :object

    def initialize(object)
      @object = object
      super('Billing address is not correctly set')
    end
  end

  included do
    validates :billing_address_name,     presence: { if: :billing_address? }
    validates :billing_address_address1, presence: { if: :billing_address? }
    validates :billing_address_city,     presence: { if: :billing_address? }
    validates :billing_address_country,  presence: { if: :billing_address? }

    after_validation :copy_errors_to_billing_address
  end

  class Address

    attr_reader :data
    attr_accessor :name, :address1, :address2, :city, :country, :state, :zip, :phone, :errors

    # We alias line* and address to make it quack like a
    # ThreeScale::Address (needed in invoice model)
    alias line1 address1
    alias line2 address2

    def initialize(data = {})
      data.each { | key, value | send("#{key}=", value) }
      @data = data

      @errors = ActiveModel::Errors.new self
    end

    ATTRIBUTES = %i[company address address1 address2 phone_number city country state zip].freeze

    def to_hash
      ATTRIBUTES.map do |attribute|
        [attribute, self[attribute]]
      end.to_h
    end

    def to_xml(options = {})
      xml = options[:builder] || ThreeScale::XML::Builder.new
      xml.__send__(options.fetch(:root, :billing_address)) do |xml|
        to_hash.each do |attr, value|
          xml.__send__(attr, value)
        end
      end

      xml.to_xml
    end

    # Quacking like Hash makes BillingAddress compatible with
    # ActiveMerchant. See AuthorizeNetCimGateway#add_address for interface.
    #
    def [](key)
      case key
      when :company then name
      when :address then [ address1, address2 ].compact.join("\n")
      when :phone_number then phone
      when :city, :country, :state, :zip, :address1, :address2 then send(key)
      end
    end

    def to_s
      attrs = %i[address phone city country state zip]
      attrs.map {|attr| self[attr].presence}.compact.join(', ')
    end

  end

  # Somehow this is different than <tt>#billing_address?</tt> and it's used
  # when a payment gateway needs a billing address before entering CC data.
  def has_billing_address?
    !billing_address_name.nil?
  end

  def billing_address?
    !@billing_address_set.nil?
  end

  def billing_address
    @billing_address ||= Address.new({
                                       name:     billing_address_name.presence || org_name,
      address1: billing_address_address1,
      address2: billing_address_address2,
      country:  billing_address_country || default_country,
      city:     billing_address_city,
      state:    billing_address_state,
      zip:      billing_address_zip,
      phone:    billing_address_phone || telephone_number
                                     })
  end

  def billing_address=(address)
    raise Account::BillingAddress::AddressFormatError, self unless address.respond_to?(:each)
    @billing_address_set = true
    address.each do | key, value |
      send("billing_address_#{key}=", value)
    end
    @billing_address= Address.new(address)
  end

  def delete_billing_address
    %i[address1 address2 name phone city country state zip].each do |attr|
      send("billing_address_#{attr}=", nil)
    end
    @billing_address = nil
    @billing_address_set = nil
  end

  def copy_errors_to_billing_address
    %i[name address1 city country].each do | field |
      errors["billing_address_#{field}"].each do | error |
        billing_address.errors.add field, error
      end
    end
  end

  def reload(*)
    super.tap do
      @billing_address_set = nil
      @billing_address = nil
    end
  end

  private

  def default_country
    country&.code
  end
end
