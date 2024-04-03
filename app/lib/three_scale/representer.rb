require 'roar/decorator'
require 'roar/representer'
require 'roar/hypermedia'

class ThreeScale::Representer < Roar::Decorator
  include Roar::Representer
  include Roar::Hypermedia
  include Representable::Hash

  undef :to_json if method_defined?(:to_json)

  # @return [Class] either specific format subclass or self
  def self.format(format)
    const = format.to_s.upcase
    const_defined?(const, false) ? const_get(const, false) : self
  end

  module Wrapping
    def wraps_resource(root = true)
      self.representation_wrap = root
    end
  end
  extend Wrapping
end
