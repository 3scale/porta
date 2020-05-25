# frozen_string_literal: true

module ThreeScale::DomainSubstitution
  module Request
    def internal_host
      Substitutor.to_internal(host)
    end
  end

  class Substitutor
    def self.config
      Rails.application.config.domain_substitution
    end

    def self.request_pattern
      @request_pattern ||= Regexp.compile config.request_pattern.to_s
    end

    def self.request_replacement
      @request_replacement ||= config.request_replacement.to_s
    end

    def self.response_pattern
      @response_pattern ||= Regexp.compile config.response_pattern.to_s
    end

    def self.response_replacement
      @response_replacement ||= config.response_replacement.to_s
    end

    def self.enabled?
      config.enabled
    end

    # to_internal a request host to system host
    def self.to_internal(host)
      return host unless enabled?

      host.to_s.sub(request_pattern, request_replacement)
    end

    # to_internal a system host to a request host
    def self.to_external(host)
      return host unless enabled?

      host.to_s.sub(response_pattern, response_replacement)
    end
  end
end

[Rack::Request, ActionDispatch::Request].each do |klass|
  klass.prepend(ThreeScale::DomainSubstitution::Request)
end
