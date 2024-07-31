# frozen_string_literal: true

module Annotating
  module Model
    extend ActiveSupport::Concern

    included do
      has_many :annotations, as: :annotated, dependent: :destroy, autosave: true
    end

    def annotations=(list)
      list.each do |a|
        annotate(a[:name], a[:value])
      end
    end

    def annotation(name)
      annotations.find { _1.name == name }
    end

    def value_of_annotation(name)
      annotation(name)&.value
    end

    def annotate(name, value)
      return remove_annotation(name) if value.blank?

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
