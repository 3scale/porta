# frozen_string_literal: true
ActiveRecord::Base.prepend(Module.new do
  def save_has_one_association(reflection)
    if reflection.options[:through]
      Rails.logger.debug "Hit Rails bug - won't save has_one through association"
    else
      super(reflection)
    end
  end
end)
