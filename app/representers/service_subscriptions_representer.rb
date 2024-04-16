# frozen_string_literal: true

class ServiceSubscriptionsRepresenter < ThreeScale::CollectionRepresenter
  class JSON < ServiceSubscriptionsRepresenter
    include ThreeScale::JSONRepresenter
    # include Roar::JSON::Collection
    wraps_resource :service_subscriptions
    items extend: ServiceSubscriptionRepresenter
  end

  class XML < ServiceSubscriptionsRepresenter
    include Roar::XML
    wraps_resource :service_subscriptions
    items extend: ServiceSubscriptionRepresenter
  end
end
