# frozen_string_literal: true

class ServiceSubscriptionsRepresenter < ThreeScale::CollectionRepresenter
  include ThreeScale::JSONRepresenter
  wraps_resource :service_subscriptions
  items extend: ServiceSubscriptionRepresenter
end
