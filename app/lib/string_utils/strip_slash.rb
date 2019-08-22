# frozen_string_literal: true

module StringUtils
  # Might be good to add it to String but I do not like that
  module StripSlash
    module_function

    def strip_slash(value)
      value.to_s.gsub(/(^\/+)|(\/+$)/,'')
    end
  end
end
