# frozen_string_literal: true

require 'test_helper'

class ExceptionReportingTest < ActiveSupport::TestCase
  def raise_exception
    raise 'Booom!'
  end

  class DevEnvTest < ExceptionReportingTest
    def setup
      Rails.env.stubs(:test?).returns(false)
      Rails.env.stubs(:development?).returns(true)
    end

    test 'raise' do
      assert_raise(RuntimeError) do
        report_and_supress_exceptions { raise_exception }
      end
    end
  end

  class TestEnvTest < ExceptionReportingTest
    def setup
      Rails.env.stubs(:test?).returns(true)
      Rails.env.stubs(:development?).returns(false)
    end

    test 'raise' do
      assert_raise(RuntimeError) do
        report_and_supress_exceptions { raise_exception }
      end
    end
  end

  class OtherEnvTest < ExceptionReportingTest
    def setup
      Rails.env.stubs(:test?).returns(false)
      Rails.env.stubs(:development?).returns(false)
    end

    test 'other env log' do
      Rails.logger.expects(:error)
      report_and_supress_exceptions { raise_exception }
    end

    test 'other env report an error' do
      System::ErrorReporting.expects(:report_error)
      report_and_supress_exceptions { raise_exception }
    end
  end

  def self.runnable_methods
    return [] if self == ExceptionReportingTest

    super
  end
end
