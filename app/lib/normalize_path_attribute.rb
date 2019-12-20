# frozen_string_literal: true

# This module normalizes uri to valid format
# the process is like this:
#   * if url is invalid => add validation error and replace the value
#   * if user sees the form again, he will see "normalized" url so he can verify all is ok
#   * user saves the form again and saves the normalized value
#
#
# use it like this:
#
# include NormalizePathAttribute
# verify_path_format :path
#

require 'addressable/uri'

module NormalizePathAttribute
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def verify_path_format(*attrs)
      attrs.each do |attr|
        validate do |record|
          value = record.read_attribute(attr)

          # skip empty values
          next if value.blank?

          begin
            URI.parse(value)
          rescue URI::InvalidURIError
            # normalize url according to rfc
            normalized = normalize_path(value)

            # write it back to the record and add error message
            # so we prevent save and on next time this won't be happening
            record.send(:write_attribute, attr, normalized)
            record.errors.add(attr, :invalid_uri)
          end
        end
      end
    end
  end

  def normalize_path(old_path)
    path = old_path.dup
    if path
      path.gsub!(%r{[^/\w-]+}, '-') # only letters, digits, - and _ are allowed
      path.gsub!(/[-]+/, '-')       # no doble dashes
      path.gsub!(/\A[-]+/, '')      # no dashes at the beginning
      path.gsub!(/[-]+\Z/, '')      # no dashes at the end
      path.gsub!(%r{/-}, '/')       # no dash after slashes
      path.gsub!(%r{-/}, '/')       # no dash before slashes
    end
    path
  end
end
