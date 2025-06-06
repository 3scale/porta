# frozen_string_literal: true

module UriUtils
  module_function

  def strip_fragment(uri_string)
    new_uri = URI(uri_string)
    new_uri.fragment = nil
    new_uri.to_s
  rescue URI::InvalidURIError
    nil
  end
end
