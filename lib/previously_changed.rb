# frozen_string_literal: true

module PreviouslyChanged
  extend ActiveSupport::Concern

  def previously_changed?(attribute)
    saved_change_to_attribute?(attribute)
  end
end
