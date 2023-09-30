# frozen_string_literal: true

module ManagedBy
  extend ActiveSupport::Concern

  def managed_by
    value_of_annotation("managed")
  end

  def managed_by=(value)
    annotate("managed", value)
  end
end
