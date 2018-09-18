module Apicast
  class LuaGenerator < AbstractGenerator
    abstract!

    self.formats = %I[lua]
    self.view_paths = File.join(__dir__, 'templates')

    def filename
      raise NotImplementedError, "This #{self.class} cannot respond to: #{__method__}"
    end

    def emit(_provider)
      super()
    end
  end
end
