require 'test_helper'

class Liquid::Tags::MenuTest < ActiveSupport::TestCase
  def setup
    template = Liquid::Template.parse('{% menu %}')
    @menu = template.root.nodelist.first
  end

  class FileSystem < Liquid::BlankFileSystem
    def read_template_file(template_path)
      "menu content for #{template_path}"
    end
  end

  test 'render' do
    Liquid::Template.file_system = FileSystem.new

    template = Liquid::Template.parse('{% menu %}')
    result = template.render

    assert_includes result, 'menu content for menu'
  ensure
    Liquid::Template.file_system = Liquid::BlankFileSystem.new
  end
end

