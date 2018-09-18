class ServiceGenerator < Rails::Generators::NamedBase
  check_class_collision suffix: 'Service'

  def create_service
    create_file "app/services/#{file_name}_service.rb" do
      <<-TEMPLATE
class #{class_name}Service
end
TEMPLATE
    end
  end

  def create_service_test
    create_file "test/unit/services/#{file_name}_service_test.rb" do
      <<-TEMPLATE
require 'test_helper'

class #{class_name}ServiceTest < ActiveSupport::TestCase
  def setup
    @#{file_name} = #{class_name}Service.new
  end

  def test_
    assert @#{file_name}
  end
end
TEMPLATE
    end
  end
end
