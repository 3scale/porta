# frozen_string_literal: true

# FIXME: remove that hack. use the api in the way it is intended to be
# used (Aurelian)

# Little hack that disables layout by default on ajax request
module LayoutlessAjaxRendering
  extend ActiveSupport::Concern

  included do
    class_attribute :layoutless_rendering
    self.layoutless_rendering = true
  end

  # this method is called by render to get options
  def _normalize_args(*)
    super.tap do |options|
      options[:layout] ||= false if layoutless?
    end
  end

  protected

  def layoutless?
    layoutless_rendering && request.xhr?
  end
end
