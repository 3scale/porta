# frozen_string_literal: true

require 'three_scale/deprecation'

module ThreeScale::DomainSubstitution


  module Request
    def internal_host
      Substitutor.to_internal(host)
    end
  end

  # Transforms a admin domain from the database to proxied domain.
  #   Example:
  #
  #     An external proxied domain provider-admin.proxied-domain.com
  #     maps to an Account with provider-admin.example.com in the Database
  #
  #     account.provider?
  #     # => true
  #
  #     account['domain']
  #     # => "provider.example.com"
  #
  #     account['self_domain']
  #     # => "provider-admin.example.com"
  #
  #     account.external_domain
  #     # => "provider.proxied-domain.com"
  #
  #     account.external_admin_domain
  #     # => "provider-admin.proxied-domain.com"
  #
  #
  module Account
    extend ActiveSupport::Concern

    def internal_domain
      self['domain']
    end

    def internal_admin_domain
      admin_domain
    end

    def internal_self_domain
      self['self_domain']
    end

    def external_self_domain
      ThreeScale::DomainSubstitution.to_external(self['self_domain'])
    end

    def external_domain
      ThreeScale::DomainSubstitution.to_external(self['domain'])
    end

    def external_admin_domain
      ThreeScale::DomainSubstitution.to_external(admin_domain)
    end

    def match_internal_admin_domain?(host)
      internal_admin_domain == host
    end

    # This methods should not be used
    # Use match_internal_admin_domain? instead
    # It will work for provider and developer
    def match_internal_self_domain?(host)
      internal_self_domain == host
    end

    def match_internal_domain?(host)
      internal_domain == host
    end

    deprecate domain: "use #internal_domain",
      self_domain: "use #internal_admin_domain",
      match_internal_self_domain?: "use #match_internal_admin_domain?",
      deprecator: ThreeScale::Deprecation::Deprecator.new
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
