# frozen_string_literal: true

class Annotation < ApplicationRecord
  SUPPORTED_ANNOTATIONS = %w[managed].freeze

  belongs_to :annotated, polymorphic: true

  validates :name, presence: true, inclusion: { in: SUPPORTED_ANNOTATIONS }
end
