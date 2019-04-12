require 'test_helper'

class SystemDatabaseTest < ActiveSupport::TestCase

  def test_configuration_specification_is_memoized
    FakeFS do
      expected_config = System::Database.configuration_specification
      assert_instance_of ActiveRecord::ConnectionAdapters::ConnectionSpecification, expected_config
      config_path = Rails.root.join('config', 'database.yml')

      FakeFS::FileSystem.clone(config_path.dirname.to_s)
      FakeFS::FileUtils.rm(config_path.to_s)
      config = System::Database.configuration_specification

      assert_same expected_config, config
    end
  end
end
