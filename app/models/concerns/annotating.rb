# frozen_string_literal: true

module Annotating
  extend ActiveSupport::Concern

  class_methods do
    def annotated
      class_eval do
        include Model
        include ManagedBy
      end
    end
  end

  class << self
    def models
      return @models if @models

      Zeitwerk::Loader.eager_load_all # this is to see all models in dev env, otherwise some may not be yet loaded
      @models = ActiveRecord::Base.descendants.select { |model| model.include?(Model) }
    end
  end

  module Model
    extend ActiveSupport::Concern

    included do
      has_many :annotations, as: :annotated, dependent: :destroy, autosave: true
    end

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
