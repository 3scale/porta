# frozen_string_literal: true

module CMS
  module S3
    extend self

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
      opts = config.slice(:force_path_style)
      opts[:endpoint] = [protocol, hostname].join('://') if protocol && hostname
      opts
    end

    def stub!
      @config ||= { bucket: 'test', access_key_id: 'key', secret_access_key: 'secret', region: 'us-east-1' }
      Aws.config[:s3] = { stub_responses: true }
      enable!
    end

    private

    def config
      @config ||= Rails.application.config.s3.try(:symbolize_keys)
    rescue IndexError, KeyError
      raise NoConfigError, "No S3 config for #{Rails.env} environment"
    end
  end
end

CMS::S3.enable!
