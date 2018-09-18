require 'test_helper'

class Liquid::Tags::MenuTest < ActiveSupport::TestCase
  def setup
    @menu = Liquid::Tags::Menu.parse('menu', '', [], {})
  end

  class FileSystem < Liquid::BlankFileSystem
    def read_template_file(file, context)
      read_file(file, context)
    end
  end

  test 'render' do
    context = Liquid::Context.new
    file_system = FileSystem.new
    Liquid::Template.stubs(file_system: file_system)
    file_system.expects(:read_file).with('menu', context)

    @menu.render(context)
  end
end

