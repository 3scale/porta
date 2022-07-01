require 'test_helper'

class ProcessDomainEventsWorkerTest < ActiveSupport::TestCase

  def test_enqueue
    proxy = FactoryBot.create(:simple_proxy)
    event = Domains::ProxyDomainsChangedEvent.create(proxy)
    ProcessDomainEventsWorker.enqueue(event)
  end

  def test_proxy_domain_changed_event
    provider = FactoryBot.create(:simple_provider)
    proxy = FactoryBot.create(:simple_proxy)
    proxy.update_attributes!(endpoint: "http://#{provider.internal_admin_domain}")
    event = Domains::ProxyDomainsChangedEvent.create_and_publish!(proxy)

    provider_domains_changed = EventStore::Repository.adapter.where(event_type: 'Domains::ProviderDomainsChangedEvent')

    assert_difference provider_domains_changed.method(:count) do
      ProcessDomainEventsWorker.new.perform(event.event_id)
    end
  end

  def test_provider_domain_changed_event
    provider = FactoryBot.create(:simple_provider)
    proxy = FactoryBot.create(:simple_proxy)
    proxy.update_attributes!(endpoint: "http://#{provider.internal_admin_domain}")
    event = Domains::ProviderDomainsChangedEvent.create_and_publish!(provider)

    proxy_domains_changed = EventStore::Repository.adapter.where(event_type: 'Domains::ProxyDomainsChangedEvent')

    assert_difference proxy_domains_changed.method(:count) do
      ProcessDomainEventsWorker.new.perform(event.event_id)
    end
  end
end
