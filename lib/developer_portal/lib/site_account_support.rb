# frozen_string_literal: true

# Include this into controller to enable site_account support.
module SiteAccountSupport
  def self.included(base)
    base.class_eval do
      helper_method :site_account
      helper_method :domain_account
    end
  end

  private

  class NoAccountForDomain < ActiveRecord::RecordNotFound
    def initialize(request)
      super "Couldn't find an account for domain #{request.try(:host)}"
    end
  end

  def domain_account
    @domain_account ||= site_account_request.domain_account or raise NoAccountForDomain.new(request)
  end

  delegate :site_account, :site_account_by_provider_key, to: :site_account_request

  def site_account_request
    @_site_account_request ||= SiteAccountSupport::Request.new(request)
  end

  # Am I on the domain of my provider?
  def provider_domain?
    @_provider_domain ||= current_account.provider_account == site_account
  end

  # Use this as before filter, to make sure the action is performed on the
  # admin domain for the provider account
  def force_provider_domain
    if current_account && !provider_domain? && request.get?
      redirect_to_domain(current_account.admin_domain)
    end
  end

  def force_provider_or_master_domain
    unless ThreeScale.tenant_mode.master? || Account.is_admin_domain?(request.host) || Account.is_master_domain?(request.host)
      render_error 'Access denied', :status => :forbidden
    end
  end

  def buyer_domain?
    @_buyer_domain ||= !Account.is_admin_domain?(request.host)
  end

  def admin_domain?
    current_account.self_domain == request.host
  end

  class Request
    attr_reader :request
    private :request

    delegate :tenant_mode, to: ThreeScale
    delegate :host, to: :request, allow_nil: true

    module MasterDomainWildcard
      def find_provider
        Account.master_on_premises || super
      end

      def domain_account
        Account.master_on_premises || super
      end

      def site_account_by_provider_key
        return unless (key = provider_key.presence)
        if ThreeScale.master_on_premises?
          Account.where(master: true).find_by_provider_key!(key) || super
        else
          super
        end
      end

      def site_account_by_domain
        Account.master_on_premises || super
      end

    end
    prepend MasterDomainWildcard

    def initialize(request)
      @request = request.try!(:dup)
      @request.try!(:extend, ThreeScale::DevDomain::Request) if ThreeScale::DevDomain.enabled?
    end

    def find_provider
      Account.providers_with_master.find_by!(self_domain: host)
    end

    def domain_account
      Account.find_by(self_domain: host)
    end

    def site_account
      @_site_account ||= site_account_by_provider_key || site_account_by_domain or raise NoAccountForDomain.new(request)
    end

    def site_account_by_provider_key
      return unless (key = provider_key.presence)
      Account.providers_with_master.by_self_domain(host).find_by_provider_key!(key)
    end

    def site_account_by_domain
      site = Account.find_by(self_domain: host)
      if site
        site.provider_account
      else
        Account.find_by(domain: host)
      end
    end

    private


    def provider_key
      request.params[:provider_key]
    end
  end
end
