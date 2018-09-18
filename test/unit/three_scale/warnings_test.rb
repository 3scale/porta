require 'test_helper'

class ThreeScale::WarningsTest < ActiveSupport::TestCase

  subject { ThreeScale::Warnings }

  test 'report to airbrake' do
    System::ErrorReporting.expects(:report_error).with(instance_of(ThreeScale::Warnings::DeprecationError), any_parameters)

    subject.deprecated_method(:name)
  end

  test 'raise exception' do
    assert_raise(ThreeScale::Warnings::DeprecationError) do
      subject.deprecated_method!(:name)
    end
  end

  test 'exception backtrace' do
    begin
      subject.deprecated_method!(:name)
    rescue ThreeScale::Warnings::DeprecationError => error
      assert_match /three_scale\/warnings_test/, error.backtrace.first
    end
  end

end
