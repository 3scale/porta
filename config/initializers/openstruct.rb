# TODO: this initializer is no longer needed when updating to ruby 2.1
# https://github.com/ruby/ruby/commit/e44e356b53828d6468114b30e5c169296896f9b1
require 'ostruct'

module OpenStructCompat
  def [](name)
    @table[name.to_sym]
  end

  def []=(name, value)
    modifiable[new_ostruct_member(name)] = value
  end
end


class OpenStruct
  include OpenStructCompat
end