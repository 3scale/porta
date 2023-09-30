# frozen_string_literal: true

module Annotating
  extend ActiveSupport::Concern

  include ManagedBy

  class_methods do
    def annotated
      class_eval do
        has_many :annotations,  as: :annotated, dependent: :destroy, autosave: true

        def annotation(name)
          annotations.find { _1.name == name }
        end

        def value_of_annotation(name)
          annotation(name)&.value
        end

        def annotate(name, value)
          return remove_annotation(name) if value.nil?

          existing = annotation(name)
          if existing
            existing.value = value
          else
            # TODO: add DB triggers to set tenant_id
            annotations.build(name: name, value: value, tenant_id: tenant_id)
          end
        end

        def remove_annotation(name)
          existing = annotation(name)
          annotations.destroy(existing) if existing
        end
      end
    end
  end
end
