module CMS
  module S3
    extend self

    class NoConfigError < StandardError; end

    def enabled?
      !!@enabled
    end

    def enable!
      @enabled = true if options
    end

    def disable!
      @enabled = false
    end

    def bucket
      options.fetch(:bucket) if enabled?
    end

    def region
      options.fetch(:region) if enabled?
    end

    def credentials
      options.slice(:access_key_id, :secret_access_key) if enabled?
    end

    def stub!
      @options ||= { bucket: 'test', access_key_id: 'key', secret_access_key: 'secret', region: 'us-east-1' }
      Aws.config[:s3] = { stub_responses: true }
      enable!
    end

    private

    def options
      @options ||= Rails.application.config.s3.try(:symbolize_keys)
    rescue IndexError, KeyError
      raise NoConfigError, "No S3 config for #{Rails.env} environment"
    end
  end
end

CMS::S3.enable!
