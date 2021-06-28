# frozen_string_literal: true

class ProviderDecorator < ApplicationDecorator
  include System::UrlHelpers.system_url_helpers
  include PlansHelper

  delegate :can?, :settings, to: :h

  self.include_root_in_json = false

end
