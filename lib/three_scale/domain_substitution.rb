# frozen_string_literal: true

require 'three_scale/deprecation'

module ThreeScale::DomainSubstitution


  module Request
    def internal_host
      Substitutor.to_internal(host)
    end
  end

  # == Context
  # In any debugging environment. e.g. _development_,
  # - database has account super domain set to *example.com*
  # - you access the UI or with another super domain like *proxied-domain.com*
  #
  # You still want to point your browser to *http://provider-admin.proxied-domain.com*
  # and expect it to work.
  #
  # In a "_proxied_" request, we used to monkey patch +request.host+ with
  # +ThreeScale::Middleware::DevDomain+ and +ThreeScale::DevDomain+, leading to:
  # - weird behavior
  # - feature needing to know the environment.
  #   Is it development or production?
  # - monkey patching feature to make it testable locally
  #
  # === Using a proxy as a solution?
  #
  # Why not using a proxy (e.g. nginx) to replace the URL?
  #
  # Well, it would not work for server responses.
  # When the code is using +account.domain+ or the likes, it will then use
  # *provider-admin.3scale.net* instead of *provider-admin.example.com*
  #
  # == Features that do not work well
  #
  # - sidekiq web and any middleware that relies on request.host
  # - email views will render link with the incorrect domain:
  #   url are rendered with +host: account.domain+
  # - service discovery Authentication needs to craft some the url
  #   with +:host+ option
  # - SSO login will not work for the same reason
  # - whenever you use +url_for(host: account.domain)+ there is an issue
  #
  #
  # == So what solution?
  #
  # This module adds some convenient methods to be used in the correct context
  # i.e. the writer will have the responsibility to use the correct method
  #
  # - {Account#external_domain} or {Account#internal_domain}
  # - {Account#external_admin_domain} or {Account#internal_admin_domain}
  #
  # Most of the use cases:
  # - in the context of a request, use +Account#internal_\*+ methods
  # - in the context of a response, use +Account#external_\*+ methods
  #
  #
  # Examples:
  #
  #   Config file: config/domain_substitution.yml
  #
  #     development:
  #       enabled: true
  #       request_pattern: "\\.proxied-domain\\.com"
  #       request_replacement: ".example.com"
  #       response_pattern: "\\.example\\.com"
  #       response_replacement: ".proxied-domain.com"
  #
  #   In Ruby:
  #
  #     request.host
  #     # => provider-admin.proxied-domain.com
  #
  #     request.internal_host
  #     # => provider-admin.example.com
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

    # Just an alias to _#domain_ as _#domain_ will be private.
    # Use this method when checking against the database
    # or some internal checks (See lib/routing_constraints.rb)
    # @return [String] the domain of the Account
    def internal_domain
      ThreeScale::Deprecation.silence { domain }
    end

    # This is an alias to _#admin_domain_ as it is private.
    # Use this method when checking against the database
    # @return [String] the admin domain of the Account
    def internal_admin_domain
      ThreeScale::Deprecation.silence { admin_domain }
    end

    # Use this method if you want to expose the domain to the view.
    # @return [String] the mapped external domain to be used in views
    # @example
    #   root_url(host: account.external_domain)
    #   # => "https://provider.proxied-domain.com"
    def external_domain
      ThreeScale::Deprecation.silence do
        ThreeScale::DomainSubstitution::Substitutor.to_external(domain)
      end
    end

    # Use this method if you want to expose the domain to the view.
    # @return [String] the mapped external admin domain to be used in views
    # @example
    #   root_url(host: account.external_admin_domain)
    #   # => "https://provider-admin.proxied-domain.com"
    def external_admin_domain
      ThreeScale::Deprecation.silence do
        ThreeScale::DomainSubstitution::Substitutor.to_external(admin_domain)
      end
    end

    # Matches if the database value of _self_domain_ matches the host.
    # @param host [String] the host to compare
    #   with the database value of _self_domain_
    # @return [Boolean]
    def match_internal_admin_domain?(host)
      internal_admin_domain == host
    end

    # Matches if the database value of _domain_ matches the host
    # @param host [String] the host to compare
    #   with the database value of _domain_
    # @return [Boolean]
    def match_internal_domain?(host)
      internal_domain == host
    end

    deprecate domain: "use #internal_domain or #external_domain",
      self_domain: "use #internal_admin_domain or #external_admin_domain",
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
