# require 'prawn'
# require 'prawn/format'
require "prawn/measurement_extensions"
require 'gruff'
require "open-uri"

module Prawn
  class Table
    def header_color=(color)
      row(0).background_color = color
    end

    def header_text_color=(color)
      row(0).color = color
    end

    class Cell
      class << self
        prepend(Module.new do
          def make(pdf, content, options = {})
            content = content.to_s if content.is_a?(ThreeScale::Money)
            super(pdf, content, options)
          end
        end)
      end
    end
  end
end
