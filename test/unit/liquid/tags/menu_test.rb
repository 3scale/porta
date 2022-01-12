# frozen_string_literal: true

require 'test_helper'

class Liquid::Tags::MenuTest < ActiveSupport::TestCase
  def setup
    @menu = Liquid::Tags::Menu.parse('menu', '', Liquid::Tokenizer.new(''), Liquid::ParseContext.new)
  end

  class FileSystem < Liquid::BlankFileSystem
    def read_template_file(file)
      read_file(file)
    end
  end

  test 'render' do
    context = Liquid::Context.new
    file_system = FileSystem.new
    Liquid::Template.stubs(file_system: file_system)
    file_system.expects(:read_file).with('menu')

    @menu.render(context)
  end
end
