# frozen_string_literal: true

module System
  class DomainInfo
    SystemInfo = Struct.new(:master, :provider, :developer)
    APIcastInfo = Struct.new(:staging, :production)

    class << self

      def system_info(domain)
        model = Account.where(state: 'approved')

        master, provider = master_or_provider(model, domain)
        developer = model.exists?(domain: domain)

        SystemInfo.new(master, provider, developer).freeze
      end

      def apicast_info(domain)
        environment = ProxyConfig.current_versions.by_host(domain).take(2).index_by(&:environment)

        sandbox = environment['sandbox']&.sandbox_host == domain
        production = environment['production']&.production_host == domain

        APIcastInfo.new(sandbox, production).freeze
      end

      def find(domain)
        system = system_info(domain)
        apicast = apicast_info(domain)

        new(domain: domain, system: system, apicast: apicast).freeze
      end

      protected

      def master_or_provider(model, domain)
        model.where(self_domain: domain).limit(1).pluck(:master, :provider).first
      end
    end

    attr_reader :domain
    delegate :master, :provider, :developer, to: :@system
    delegate :staging, :production, to: :@apicast, prefix: :apicast

    # @param [SystemInfo] system
    # @param [APIcastInfo] apicast
    # @return [DomainInfo]
    def initialize(domain:, system:, apicast:)
      @domain = domain
      @system = system
      @apicast = apicast
    end

    def as_json(**options)
      {
        domain: domain,
        master: master || false,
        provider: provider || false,
        developer: developer || false,
        apicast: {
          staging: apicast_staging || false,
          production: apicast_production || false,
        }
      }.as_json(options)
    end
  end
end
