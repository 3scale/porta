# frozen_string_literal: true

module Annotating
  module ManagedBy
    extend ActiveSupport::Concern

    def managed_by
      value_of_annotation("managed_by")
    end

    def managed_by=(value)
      annotate("managed_by", value)
    end
  end
end
