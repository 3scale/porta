class ProcessDomainEventsWorker
  include Sidekiq::Worker

  def perform(event_id)
    event = EventStore::Repository.find_event!(event_id)
    events = find_providers(event).map { |provider| Domains::ProviderDomainsChangedEvent.create(provider, event) }
    events += find_proxies(event).map { |proxy| Domains::ProxyDomainsChangedEvent.create(proxy, event) }

    events.each(&:publish)
  end


  def find_providers(event)
    domains = event.domains
    providers = Account.providers

    providers = case event
                when Domains::ProviderDomainsChangedEvent
                  providers.where.not(id: event.provider.id)
                else
                  providers
                end

    providers.where.has { domain.in(domains).or self_domain.in(domains) }
  end

  def find_proxies(event)
    domains = event.domains
    proxies = Proxy

    proxies = case event
              when Domains::ProxyDomainsChangedEvent
                proxies.where.not(id: event.proxy.id)
              else
                proxies
              end

    proxies.where.has { production_domain.in(domains).or staging_domain.in(domains) }
  end

  def self.enqueue(event)
    return unless ThreeScale.config.onpremises
    return if event.parent_event?

    perform_async(event.event_id)
  end
end
