module Apicast
  class ConfGenerator < AbstractGenerator
    abstract!

    self.view_paths = File.join(__dir__, 'templates').freeze
    self.formats = [:conf]
  end
end
