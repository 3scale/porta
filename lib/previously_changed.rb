# frozen_string_literal: true

module PreviouslyChanged
  extend ActiveSupport::Concern

  def previously_changed?(attribute)
    Array(previous_changes[attribute.to_s]).any?
  end
end
