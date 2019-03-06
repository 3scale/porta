# frozen_string_literal: true

class DeletedObjectEntry < ApplicationRecord
  belongs_to :owner, polymorphic: true
  belongs_to :object, polymorphic: true

  [Metric, Contract].each do |scoped_class|
    scope scoped_class.to_s.underscore.pluralize.to_sym, -> { where(object_type: scoped_class) }
  end

  # TODO: cleanup regularly once the owner is destroyed too :) or this will grow uncontrollably
end
