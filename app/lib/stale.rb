# frozen_string_literal: true

module Stale
  # The API responder performs conditional GET and only produces the response for stale objects,
  # but calling `stale?` for controllers that deal with objects that are not ActiveRecord descendants fails
  # because it relies on `updated_at` field which is not available
  # In such cases the object will always be considered stale
  def stale?(object = nil, **freshness_kwargs)
    has_updated_at = object.respond_to?(:updated_at) || object&.all? { _1.respond_to? :updated_at }
    return super if has_updated_at

    true
  end
end
