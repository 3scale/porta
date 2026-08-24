# frozen_string_literal: true

module Apicast
  module PcreEscaper
    PATH_METACHARACTERS = /[.()*+]/
    QUERY_METACHARACTERS = /[.()*+$?\[\]]/

    def self.escape(pattern)
      return pattern if pattern.blank?

      # ? is not valid in path segments, so splitting on the first ? is safe
      path_part, query_part = pattern.split('?', 2)

      escaped_path = path_part.gsub(PATH_METACHARACTERS) { "\\#{Regexp.last_match(0)}" }

      if query_part
        "#{escaped_path}?#{query_part.gsub(QUERY_METACHARACTERS) { "\\#{Regexp.last_match(0)}" }}"
      else
        escaped_path
      end
    end
  end
end
