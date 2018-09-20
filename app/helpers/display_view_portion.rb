# frozen_string_literal: true

module DisplayViewPortion
  def display_view_portion!(name)
    @__view_portion_to_display ||= {}
    @__view_portion_to_display[name] = true
  end

  module Helper
    def display_view_portion?(name)
      (@__view_portion_to_display || {}).fetch(name, false)
    end
  end
end
