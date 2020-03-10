# frozen_string_literal: true

require 'test_helper'

class UriValidatorTest < ActiveSupport::TestCase
  class ModelWithURIValidation
    include ActiveModel::Validations

    def self.model_name
      ActiveModel::Name.new(self, nil, "uri_validator_test__base_klass")
    end

    attr_accessor :uri

    validates :uri, uri: true
  end

  test 'invalid uri' do
    record = ModelWithURIValidation.new

    %w[missing.scheme:9 fdsfas not_&_valid &/(\\'].each do |invalid_uri|
      record.uri = invalid_uri
      refute record.valid?
    end
  end

  test 'default format http(s)://host(:port)' do
    record = ModelWithURIValidation.new

    %w[http https].each do |scheme|
      record.uri = "#{scheme}://domain.test"
      assert record.valid?

      record.uri = "#{scheme}://domain.test:123"
      assert record.valid?
    end
  end

  test '/path' do
    record = ModelWithURIValidation.new
    record.uri = "http://domain.test/path"
    refute record.valid?
    assert_equal 'is invalid', record.errors[:uri].to_sentence

    with_clean_validators ModelWithURIValidation do
      [true, false].each do |valid_path|
        klass = Class.new(ModelWithURIValidation) { validates :uri, uri: { path: valid_path } }
        record = klass.new
        record.uri = "http://domain.test/path"
        assert_equal valid_path, record.valid?
      end
    end
  end

  test 'custom scheme' do
    record = ModelWithURIValidation.new
    record.uri = "ssh://domain.test"
    refute record.valid?

    with_clean_validators ModelWithURIValidation do
      klass = Class.new(ModelWithURIValidation) { validates :uri, uri: { scheme: 'ssh' } }
      record = klass.new
      record.uri = "ssh://domain.test"
      assert record.valid?

      klass = Class.new(ModelWithURIValidation) { validates :uri, uri: { scheme: %w[pop imap] } }
      record = klass.new
      record.uri = "pop://domain.test"
      assert record.valid?
      record.uri = "imap://domain.test"
      assert record.valid?

      klass = Class.new(ModelWithURIValidation) { validates :uri, uri: { scheme: /^s?ftp$/ } }
      record = klass.new
      record.uri = "ftp://domain.test"
      assert record.valid?
      record.uri = "sftp://domain.test"
      assert record.valid?
      record.uri = "tftp://domain.test"
      refute record.valid?
    end
  end

  test 'hostname with label longer than 63 chars' do
    record = ModelWithURIValidation.new
    record.uri = "http://#{long_hostname_label}.#{short_hostname_label}.test"
    refute record.valid?
    error_message = record.errors[:uri].to_sentence
    assert_match /is too long for one or more labels of the host \(maximum is 63 characters\)/, error_message
    assert_not_match /invalid/, error_message
  end

  test 'hostname with labels up to 63 chars' do
    record = ModelWithURIValidation.new
    short_labels = (1..2).map { |count| "#{short_hostname_label}-#{count}" }
    record.uri = "http://#{short_labels.join('.')}.test"
    assert record.valid?
  end

  test 'hostname longer than 255 with labels up to 63 chars' do
    record = ModelWithURIValidation.new
    short_labels = (1..13).map { |count| "#{short_hostname_label}-#{count}" }
    record.uri = "http://#{short_labels.join('.')}.test" # hostname with 275 chars
    refute record.valid?
    error_message = record.errors[:uri].to_sentence
    assert_match /is too long \(maximum is 255 characters\)/, error_message
    assert_not_match /invalid/, error_message
  end

  test 'hostname up to 255 with labels up to 63 chars' do
    record = ModelWithURIValidation.new
    short_labels = (1..12).map { |count| "#{short_hostname_label}-#{count}" }
    record.uri = "http://#{short_labels.join('.')}.test" # hostname with 254 chars
    assert record.valid?
  end

  test 'forbid optional parts' do
    record = ModelWithURIValidation.new
    record.uri = "http://domain.test:123"
    assert record.valid?

    with_clean_validators ModelWithURIValidation do
      klass = Class.new(ModelWithURIValidation) { validates :uri, uri: { port: false } }
      record = klass.new
      record.uri = "http://domain.test:123"
      refute record.valid?
    end
  end

  private

  def with_clean_validators(klass)
    validate_callbacks = klass._validate_callbacks
    klass.clear_validators!
    yield
    klass._validate_callbacks = validate_callbacks
  end

  def long_hostname_label
    'this-hostname-label-is-longer-than-63-chars-which-is-not-allowed-according-to-rfc-1035' # 86 chars
  end

  def short_hostname_label
    'short-label-is-ok' # 17 chars
  end
end
