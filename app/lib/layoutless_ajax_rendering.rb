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

  PJAX = 'X-PJAX'

  # this method is called by render to get options
  def _normalize_args(*)
    super.tap do |options|
      options[:layout] ||= false if layoutless_rendering && (request.xhr? || request.headers[PJAX])
    end
  end
end
