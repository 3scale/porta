class QueryGenerator < Rails::Generators::NamedBase
  check_class_collision suffix: 'query'

  def create_query
    create_file "app/queries/#{file_name}.rb" do
      <<-TEMPLATE
class #{class_name}
end
      TEMPLATE
    end
  end

  def create_query_test
    create_file "test/unit/queries/#{file_name}_test.rb" do
      <<-TEMPLATE
require 'test_helper'

class #{class_name}Test < ActiveSupport::TestCase
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
    "#{super}_query"
  end
end
