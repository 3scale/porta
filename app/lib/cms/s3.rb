# frozen_string_literal: true

module CMS
  module S3
    extend self

    FIPS_FILE_PATH = "/proc/sys/crypto/fips_enabled"

    class NoConfigError < StandardError; end

    def enabled?
      !!@enabled
    end

    def enable!
      @enabled = true if config
    end

    def disable!
      @enabled = false
    end

    def fips_environment?
      ::File.file?(FIPS_FILE_PATH) && ::File.read(FIPS_FILE_PATH).strip != "0"
    rescue
      false
    end

    def bucket
      config.fetch(:bucket) if enabled?
    end

    def region
      config.fetch(:region) if enabled?
    end

    def credentials
      config.slice(:access_key_id, :secret_access_key) if enabled?
    end

    def hostname
      config[:hostname].presence if enabled?
    end

    def protocol
      config[:protocol].presence || 'https' if enabled?
    end

    def options
      return unless enabled?

      opts = config.slice(:force_path_style, :use_fips_endpoint)
      opts[:endpoint] = [protocol, hostname].join('://') if protocol && hostname
      # if endpoint was specified, then :use_fips_endpoint should be redundant
      opts[:use_fips_endpoint] = true if !opts.key?(:use_fips_endpoint) && opts[:endpoint].blank? && fips_environment?
      if opts[:use_fips_endpoint]
        raise ArgumentError, "AWS fips endpoints support only virtual hosted addresses so :use_fips_endpoint and :force_path_style are incompatible" if opts[:force_path_style]
        raise ArgumentError, "bucket names with dots will force path_style addressing which is unsupported by AWS fips endpoints" if bucket.include?(".")

        opts[:s3_us_east_1_regional_endpoint] = "regional"
      end
      opts
    end

    def stub!
      @config ||= { bucket: 'test', access_key_id: 'key', secret_access_key: 'secret', region: 'us-east-1' }
      Aws.config[:s3] = { stub_responses: true }
      enable!
    end

    private

    def config
      @config ||= Rails.application.config.s3.try(:symbolize_keys).presence
    rescue IndexError, KeyError
      raise NoConfigError, "No S3 config for #{Rails.env} environment"
    end
  end
end

CMS::S3.enable!
