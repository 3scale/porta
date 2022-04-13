# frozen_string_literal: true

module PreviouslyChanged
  extend ActiveSupport::Concern

  def previously_changed?(attribute)
    raise 'crap' if previous_changes[attribute.to_s] != saved_changes[attribute.to_s]
    saved_change_to_attribute?(attribute)
  end
end
