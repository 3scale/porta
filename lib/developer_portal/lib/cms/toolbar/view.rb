# frozen_string_literal: true

module CMS::Toolbar
  class View < ActionView::Base
    include System::UrlHelpers.system_url_helpers
    include DeveloperPortal::CMS::ToolbarHelper
  end
end
