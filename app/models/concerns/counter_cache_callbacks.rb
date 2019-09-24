# frozen_string_literal: true

module CounterCacheCallbacks
  extend ActiveSupport::Concern

  included do
    after_save :update_counter_cache
    after_destroy :update_counter_cache
  end

  def update_counter_cache
    Array(reset_counter_cache_for).each do |association_name|
      public_send(association_name)&.reset_counter_cache if update_counter_cache?(association_name)
    end
  end

  protected

  def reset_counter_cache_for
    raise NotImplementedError
  end

  def update_counter_cache?(_association_name)
    true
  end
end
