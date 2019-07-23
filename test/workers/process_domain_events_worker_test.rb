require 'test_helper'

class ProcessDomainEventsWorkerTest < ActiveSupport::TestCase
  def test_proxy_domain_changed_event
    provider = FactoryBot.create(:simple_provider)
    proxy = FactoryBot.create(:simple_proxy)
    proxy.update_attributes!(endpoint: "http://#{provider.admin_domain}")
    event = Domains::ProxyDomainsChangedEvent.create(proxy)

    provider_domains_changed = EventStore::Repository.adapter.where(event_type: 'Domains::ProviderDomainsChangedEvent')

    assert_difference provider_domains_changed.method(:count) do
      ProcessDomainEventsWorker.new.perform(event)
    end
  end

  def test_provider_domain_changed_event
    provider = FactoryBot.create(:simple_provider)
    proxy = FactoryBot.create(:simple_proxy)
    proxy.update_attributes!(endpoint: "http://#{provider.admin_domain}")
    event = Domains::ProviderDomainsChangedEvent.create(provider)

    proxy_domains_changed = EventStore::Repository.adapter.where(event_type: 'Domains::ProxyDomainsChangedEvent')

    assert_difference proxy_domains_changed.method(:count) do
      ProcessDomainEventsWorker.new.perform(event)
    end
  end
end
