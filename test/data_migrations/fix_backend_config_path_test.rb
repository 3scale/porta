# frozen_string_literal: true

require 'test_helper'

module DataMigrations
  class FixBackendConfigPathTest < DataMigrationTest
    fixtures :backend_api_configs

    setup do
      @config_without_path = backend_api_configs(:empty_path)
      @config_with_path    = backend_api_configs(:with_path)
    end

    test 'migrates all configs with empty path to have a backslash on it' do
      assert @config_without_path.path.blank?
      assert_equal '/some/path', @config_with_path.path

      FixBackendConfigPath.new.up

      assert_equal '/', @config_without_path.reload.path
      assert_equal '/some/path', @config_with_path.reload.path
    end
  end
end
