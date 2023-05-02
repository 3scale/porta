# Be sure to restart your server when you modify this file.

# Add new mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf

# Extracted from https://github.com/rails/rails/blob/6-1-stable/actionpack/lib/action_dispatch/http/mime_type.rb#L344-L346
# Mime::NullType has an odd behaviour in Rails 6 due to the check performed in
# https://github.com/rails/rails/blob/6-0-stable/actionpack/lib/action_controller/metal/mime_responds.rb#L208-L210
# where media_type and format are different even though both are Mime::NullType.
# The to_s method fixes the isse but, unfortunatelly, it was added only for Rails 6.1+.
# We may removed this patch once we upgrade Rails to 6.1.
module Mime
  class NullType
    def to_s
      ''
    end
  end
end
