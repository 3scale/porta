# frozen_string_literal: true

class UriValidator < ActiveModel::EachValidator
  DEFAULT_ACCEPTED_SCHEME = /^https?$/
  DEFAULT_PERMISSIONS_OF_PARTS = {
    port:     true,
    userinfo: false,
    registry: false,
    path:     false,
    opaque:   false,
    query:    false,
    fragment: false
  }.freeze

  def validate_each(record, attribute_name, attribute_value)
    uri_3scale_compliance_checker = UriThreeScaleComplianceChecker.new(
      uri: self.class.safe_parse_uri(attribute_value),
      permissions_parts: permissions_for_record(record),
      accepted_scheme: options.fetch(:scheme, DEFAULT_ACCEPTED_SCHEME)
    )

    errors = uri_3scale_compliance_checker.errors
    errors.each do |error|
      record.errors.add(attribute_name, error)
    end
    errors.empty?
  end

  # This smells :reek:ManualDispatch
  def permissions_for_record(record)
    permissions = options.slice(*DEFAULT_PERMISSIONS_OF_PARTS.keys).reverse_merge(DEFAULT_PERMISSIONS_OF_PARTS)
    permissions.transform_values do |option_value|
      option_value.respond_to?(:call) ? option_value.call(record) : option_value.presence
    end
  end

  def self.safe_parse_uri(value)
    URI.parse(value)
  rescue URI::InvalidURIError
    nil
  end

  class UriThreeScaleComplianceChecker
    MAX_HOST_SIZE = 255
    MAX_LABEL_SIZE = 63

    def initialize(uri:, permissions_parts:, accepted_scheme:)
      @uri = uri
      @permissions_parts = permissions_parts
      @accepted_scheme = accepted_scheme
    end

    attr_reader :uri, :permissions_parts, :accepted_scheme, :generic_error_message
    delegate :host, :scheme, to: :uri

    def errors
      return [generic_error_message] if uri.blank?

      errors_scheme | errors_host | errors_forbidden_parts
    end

    private

    def errors_scheme
      valid = case accepted_scheme
              when Regexp
                scheme =~ accepted_scheme
              else
                [*accepted_scheme].include?(scheme)
      end

      valid ? [] : [:invalid]
    end

    def errors_host
      return [:invalid] if host.blank?

      errors = []
      errors << I18n.t('errors.messages.too_long', count: MAX_HOST_SIZE) unless valid_host_size?
      errors << I18n.t('errors.messages.host_label_too_long', count: MAX_LABEL_SIZE) unless valid_host_labels?
      errors
    end

    def valid_host_size?
      host.size <= MAX_HOST_SIZE
    end

    def valid_host_labels?
      host.split('.').map(&:size).none?(&MAX_LABEL_SIZE.method(:'<'))
    end

    def errors_forbidden_parts
      contains_forbidden_parts? ? [:invalid] : []
    end

    def contains_forbidden_parts?
      permissions_parts.find do |part_name, permitted|
        uri.public_send(part_name).present? unless permitted
      end
    end
  end
end
