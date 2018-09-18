# frozen_string_literal: true

module PolicyConfigRepresenter
  include ThreeScale::JSONRepresenter

  property :name
  property :version
  property :configuration
  property :enabled
  property :errors, if: ->(*) { errors.any? }
end
