##

module PreviouslyChanged
  extend ActiveSupport::Concern

  def previously_changed?(attribute)
    Array(previous_changes[attribute.to_s]).any?
  end

  def previous_changes
    HashWithIndifferentAccess.new(@previously_changed)
  end
end
