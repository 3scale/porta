class BaseEventStoreEvent < RailsEventStore::Event

  PUBLISHER = ->(*args) { Rails.application.config.event_store.publish_event(*args) }

  module Categorizable
    extend ActiveSupport::Concern

    included do
      class_attribute :category
    end
  end

  def initialize(args = {})
    super(**args)
  end

  def publish
    PUBLISHER.call(self)
  end

  include Categorizable

  class << self

    def create_and_publish!(...)
      return unless valid?(...)

      event = create(...)

      PUBLISHER.call(event) && event
    end

    protected

    def create(*args)
      raise NotImplementedError, "expected #{self} to implement #{__method__}"
    end

    def valid?(*_args)
      true
    end
  end
end
