class ProcessDomainEventsWorker
  include Sidekiq::Worker

  class_attribute :publisher
  self.publisher = ->(*args) { Rails.application.config.event_store.publish_event(*args) }

  def perform(event)
    events = find_providers(event).map { |provider| Domains::ProviderDomainsChangedEvent.create(provider, event) }
    events += find_proxies(event).map { |proxy| Domains::ProxyDomainsChangedEvent.create(proxy, event) }

    events.each(&publisher.method(:call))
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

    super
  end
end
