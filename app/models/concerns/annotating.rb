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

      # this is to see all models in dev env, otherwise some may not be yet loaded
      Rails.autoloaders.main.eager_load_dir("#{Rails.root}/app/models") if Rails.env.development?

      @models = ActiveRecord::Base.descendants.select { |model| model.include?(Model) }
    end
  end

  module Model
    extend ActiveSupport::Concern

    included do
      has_many :annotations, as: :annotated, dependent: :destroy, autosave: true
      accepts_nested_attributes_for :annotations
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
        annotations.build(name: name, value: value)
      end
    end

    def remove_annotation(name)
      annotation(name)&.mark_for_destruction
    end
  end
end
