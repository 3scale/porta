# frozen_string_literal: true

module BackgroundDeletion
  extend ActiveSupport::Concern

  included do
    class_attribute :background_deletion, default: [], instance_writer: false
    class_attribute :background_deletion_method, default: :destroy!, instance_writer: false
  end

  def background_deletion_method_call
    send background_deletion_method
  end
end
