# frozen_string_literal: true

module Paperclip
  class GDImageProcessor < Processor
    def make
      original_geometry = Geometry.new(*FastImage.size(file))
      computed_geometry = original_geometry.resize_to(target_geometry_str)
      file.rewind
      original_geometry.to_s[/\d+x\d+/] == computed_geometry.to_s[/\d+x\d+/] ? temp_copy(file) : FastImage.resize(file, computed_geometry.width, computed_geometry.height)
    end

    private

    def target_geometry_str
      options.fetch(:geometry)
    end

    def temp_copy(source_file)
      copy = Tempfile.new(["copy", File.extname(source_file.path)])
      File.copy_stream(source_file, copy)
      source_file.rewind
      copy.rewind
      copy
    end
  end
end
