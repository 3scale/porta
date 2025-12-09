require 'test_helper'

class Liquid::Tags::MenuTest < ActiveSupport::TestCase

  class FileSystem < Liquid::BlankFileSystem
    def read_template_file(template_path)
      "menu content for #{template_path}"
    end
  end

  test 'render' do
    Liquid::Template.file_system = FileSystem.new

    template = Liquid::Template.parse('{% menu %}')
    menu = template.root.nodelist.first
    assert_instance_of Liquid::Tags::Menu, menu

    result = menu.render(Liquid::Context.new)
    assert_includes result, 'menu content for menu'
  ensure
    Liquid::Template.file_system = Liquid::BlankFileSystem.new
  end
end

