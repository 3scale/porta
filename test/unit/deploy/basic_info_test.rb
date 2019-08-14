require 'test_helper'

class BasicInfoTest < ActiveSupport::TestCase

  test 'default release is 2.0.0' do
    System::Deploy.load_info!
    assert_equal '2.0.0', System::Deploy.info.release
  end

  test 'minor and major version taken from default release' do
    System::Deploy.load_info!
    assert_equal 2, System::Deploy.info.major_version
    assert_equal 0, System::Deploy.info.minor_version
  end

  test 'custom release' do
    System::Deploy.info.expects(:release).returns('4.5.1-CR1')
    assert_equal 4, System::Deploy.info.major_version
    assert_equal 5, System::Deploy.info.minor_version
  end
end
