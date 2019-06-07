# frozen_string_literal: true

require 'test_helper'

module Features
  class LoggingConfigTest < ActiveSupport::TestCase
    def setup
      @valid_config = { 'audits_to_stdout' => true }
    end

    attr_reader :valid_config

    class EnabledDisabledTest < LoggingConfigTest
      test 'disabled when blank' do
        refute logging_config('').enabled?
        refute logging_config({}).enabled?
      end

      test 'enabled when present' do
        assert logging_config.enabled?
        assert logging_config('any_logging_type' => false).enabled?
      end
    end

    class AuditLogsToStdoutTest < LoggingConfigTest
      test 'enabled' do
        assert logging_config.config.audits_to_stdout
      end

      test 'disabled when missing, empty or false' do
        ['', {}, { 'audits_to_stdout' => false }].each { |config| refute logging_config(config).config.audits_to_stdout }
      end
    end

    private

    def logging_config(config = valid_config)
      Features::LoggingConfig.new(config)
    end
  end
end
