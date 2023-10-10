# frozen_string_literal: true

module Annotations
  # This service is mostly needed because some models use protected_attributes and some rely on strong parameters.
  # Otherwise we could do some magic with the models to transparently `accepts_nested_attributes_for :annotations`.
  # In this case though I couldn't figure out a clean way, so using a service should make it easier to refactor later.
  class AnnotateWithParamsService < ThreeScale::Patterns::Service
    # @param instance [ActiveRecord::Base] a model instance
    # @param annotations [Array<Hash>, ActionController::Parameters] annotations list
    def initialize(instance, annotations)
      self.instance = instance
      self.annotations = annotations
    end

    def call
      annotations.each do |**annotation|
        instance.annotate(name: annotation[:name], value: annotation[:value])
      end
      nil
    end

    private

    attr_accessor :annotations, :instance
  end
end
