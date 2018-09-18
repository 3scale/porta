# frozen_string_literal: true
module ActiveRecord::AutosaveAssociation
  def save_has_one_association_with_through(reflection)
    if reflection.options[:through]
      Rails.logger.debug "Hit Rails bug - won't save has_one through association"
    else
      save_has_one_association_without_through(reflection)
    end
  end
  alias_method_chain :save_has_one_association, :through
end
