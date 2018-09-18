require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class ExceptionReportingTest < ActiveSupport::TestCase
  def raise_exception
    raise 'Booom!'
  end


  context 'dev env' do
    setup do
      Rails.env.stubs(:test?).returns(false)
      Rails.env.stubs(:development?).returns(true)
    end

    should 'raise' do
      assert_raise(RuntimeError) do
        report_and_supress_exceptions { raise_exception }
      end
    end
  end

  context 'test env' do
    setup do
      Rails.env.stubs(:test?).returns(true)
      Rails.env.stubs(:development?).returns(false)
    end

    should 'raise' do
      assert_raise(RuntimeError) do
        report_and_supress_exceptions { raise_exception }
      end
    end
  end

  context 'other env' do
    setup do
      Rails.env.stubs(:test?).returns(false)
      Rails.env.stubs(:development?).returns(false)
    end

    should 'log' do
      Rails.logger.expects(:error)
      report_and_supress_exceptions { raise_exception }
    end

    should 'notify airbrake' do
      System::ErrorReporting.expects(:report_error)
      report_and_supress_exceptions { raise_exception }
    end
  end

end
