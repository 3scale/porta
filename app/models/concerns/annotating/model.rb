# frozen_string_literal: true

module Annotating
  module Model
    extend ActiveSupport::Concern

    included do
      has_many :annotations, as: :annotated, dependent: :destroy, autosave: true, inverse_of: :annotated
    end

    def annotations=(hash)
      hash.each do |k ,v|
        annotate(k, v)
      end
    end

    def annotations_hash
      annotations.pluck(:name, :value).to_h
    end

    def annotations_xml(options = {})
      xml = options[:builder] || ThreeScale::XML::Builder.new

      xml.annotations do
        annotations.each do |annotation|
          xml.tag!(annotation.name, annotation.value)
        end
      end

      xml.to_xml
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
