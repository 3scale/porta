# frozen_string_literal: true

class Annotation < ApplicationRecord
  SUPPORTED_ANNOTATIONS = %w[managed].freeze

  belongs_to :annotated, polymorphic: true

  validates :name, presence: true, inclusion: { in: SUPPORTED_ANNOTATIONS }
  validates :name, :value, :annotated_type, length: { maximum: 255 }
end
