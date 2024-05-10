# frozen_string_literal: true

require 'test_helper'

class SystemDatabaseTest < ActiveSupport::TestCase

  test 'database config is memoized' do
    FakeFS do
      expected_config = System::Database.database_config
      assert_kind_of ActiveRecord::DatabaseConfigurations::DatabaseConfig, expected_config
      config_path = Rails.root.join('config/database.yml')

      FakeFS::FileSystem.clone(config_path.dirname.to_s)
      FakeFS::FileUtils.rm(config_path.to_s)
      config = System::Database.database_config

      assert_same expected_config, config
    end
  end
end
