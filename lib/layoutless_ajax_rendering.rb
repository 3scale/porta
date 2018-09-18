# FIXME: remove that hack. use the api in the way it is intended to be
# used (Aurelian)

# Little hack that disables layout by default on ajax request
module LayoutlessAjaxRendering
  extend ActiveSupport::Concern

  included do
    class_attribute :layoutless_rendering
    self.layoutless_rendering = true
  end

  PJAX = 'X-PJAX'.freeze

  # this method is called by render to get options
  def _normalize_args(*)
    options = super

    if layoutless_rendering && !options.has_key?(:layout)
      if request.xhr? || request.headers[PJAX]
        options[:layout] = false
      end
    end

    options
  end
end
