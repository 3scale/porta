module Pdf
  module Utils
    module Cache
      # Prawn suffers a memory leak which was fixed upstream by
      # https://github.com/prawnpdf/prawn/pull/430
      # New API will require reimplementing a lot of things though
      # so fixing up that at places we use for the time being.
      module_function def clear_thread_cache
        %i(bold_char_width plain_char_width).each do |key|
          Thread.current[key] = nil
        end
      end
    end
  end
end

