# frozen_string_literal: true

module BackgroundDeletion
  extend ActiveSupport::Concern

  included do
    class_attribute :background_deletion, default: [], instance_writer: false
  end
end
