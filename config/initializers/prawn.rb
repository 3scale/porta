# require 'prawn'
# require 'prawn/format'
require "prawn/measurement_extensions"
require 'gruff'
require "open-uri"

module Prawn
  class Table
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
