# frozen_string_literal: true

module UrlHelpers
  def matches_path?(url, path)
    url =~ %r{/^(?:https?://[^/]+)?#{Regexp.quote(path)}/}
  end
end

World(UrlHelpers)
