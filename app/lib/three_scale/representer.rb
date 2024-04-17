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

  # Restore the original `Representable::representable_map` method, overridden in `Representable::Cached`,
  # which is included in all decorators (see https://github.com/trailblazer/representable/commit/b26aec4bbfe27d7c68526efd9d00c78980ed6bd4)
  # The cached method causes issues when multiple format engines are included (which is our case), because it will reuse the wrong bindings.
  # See https://github.com/trailblazer/representable/issues/180#issuecomment-169881369 for more info.
  def representable_map(options, format)
    Representable::Binding::Map.new(representable_bindings_for(format, options))
  end
end
