class PresenterGenerator < Rails::Generators::NamedBase
  check_class_collision suffix: 'Presenter'

  def create_presenter
    create_file "app/presenters/#{file_name}.rb" do
      <<-TEMPLATE
class #{class_name} < Struct.new
end
TEMPLATE
    end
  end

  def create_presenter_test
    create_file "test/unit/presenters/#{file_name}_test.rb" do
      <<-TEMPLATE
require 'test_helper'

class #{class_name}Test < Draper::TestCase
  def setup
    @#{file_name} = #{class_name}.new
  end

  def test_
    assert @#{file_name}
  end
end
TEMPLATE
    end
  end

  protected

  def file_name
    "#{super}_presenter"
  end
end
