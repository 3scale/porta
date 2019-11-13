require 'test_helper'

module Tasks
  class FixBackendConfigPathTest < ActiveSupport::TestCase
    fixtures :backend_api_configs

    setup do
      @config_without_path = backend_api_configs(:empty_path)
      @config_with_path    = backend_api_configs(:with_path)
    end

    test 'migrates all configs with empty path to have a backslash on it' do
      assert @config_without_path.path.blank?
      assert_equal '/some/path', @config_with_path.path

      execute_rake_task 'data_migration/fix_backend_config_path.rake', 'data_migration:fix_backend_config_path'

      assert_equal '/', @config_without_path.reload.path
      assert_equal '/some/path', @config_with_path.reload.path
    end
  end
end
