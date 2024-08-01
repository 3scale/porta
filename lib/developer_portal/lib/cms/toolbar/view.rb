# frozen_string_literal: true

module CMS::Toolbar
  class View < ActionView::Base
    include System::UrlHelpers.system_url_helpers
    include DeveloperPortal::CMS::ToolbarHelper
    include WebpackHelper

    # see https://github.com/rails/rails/blob/v6.1.7.7/actionview/lib/action_view/base.rb#L252-L258
    def compiled_method_container
      self.class
    end
  end
end
