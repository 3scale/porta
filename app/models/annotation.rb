# frozen_string_literal: true

class Annotation < ApplicationRecord
  SUPPORTED_ANNOTATIONS = %w[managed].freeze

  belongs_to :annotated, polymorphic: true

  validates :name, presence: true, inclusion: { in: SUPPORTED_ANNOTATIONS }

  # before_save :set_tenant_id

  private

  # def set_tenant_id
  #   return if tenant_id
  #   return if annotated.is_a?(Account) && annotated.master?
  #
  #   self.tenant_id = annotated.try(:tenant_id)
  # end
end
