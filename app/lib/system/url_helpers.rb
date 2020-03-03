# frozen_string_literal: true

module System
  module UrlHelpers
    cattr_accessor :cms_url_helpers, :system_url_helpers, instance_writer: false
    self.cms_url_helpers = DeveloperPortal::Engine.routes.url_helpers
    self.system_url_helpers =  Rails.application.routes.url_helpers
  end
end
