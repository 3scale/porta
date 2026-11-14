# frozen_string_literal: true

module Stale
  # The API responder performs conditional GET and only produces the response for stale objects,
  # but `stale?` only works for objects that implement the cache key protocol or have `updated_at`.
  # Other objects are always considered stale.
  def stale?(object = nil, **freshness_kwargs)
    return super if cacheable?(object) || (object.respond_to?(:all?) && object.all? { cacheable?(_1) })

    true
  end

  private

  def cacheable?(object)
    object.respond_to?(:cache_key_with_version) || object.respond_to?(:updated_at)
  end
end
