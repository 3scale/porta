# frozen_string_literal: true

module PreviouslyChanged
  extend ActiveSupport::Concern

  def previously_changed?(attribute)
    binding.pry if previous_changes[attribute.to_s] != saved_changes[attribute.to_s]
    saved_change_to_attribute?([attribute.to_s])
  end
end
