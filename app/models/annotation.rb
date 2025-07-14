# frozen_string_literal: true

class Annotation < ApplicationRecord
  SUPPORTED_ANNOTATIONS = %w[managed_by].freeze

  belongs_to :annotated, polymorphic: true, optional: false, inverse_of: :annotations

  validates :name, presence: true, inclusion: { in: SUPPORTED_ANNOTATIONS }
  validates :value, presence: true
  validates :name, :value, :annotated_type, length: { maximum: 255 }
end
