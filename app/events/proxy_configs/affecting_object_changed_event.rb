# frozen_string_literal: true

class ProxyConfigs::AffectingObjectChangedEvent < ServiceRelatedEvent
  def self.create(proxy, object)
    new(
      proxy_id: proxy.id,
      object_id: object.id,
      object_type: object.class.name,
      metadata: {
        service_id: proxy.service_id,
        provider_id: proxy.account.id
      }
    )
  end

  def self.valid?(proxy, *_args)
    return unless proxy
    account = proxy.account
    account && !account.scheduled_for_deletion?
  end
end
