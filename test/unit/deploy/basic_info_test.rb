require 'test_helper'

class BasicInfoTest < ActiveSupport::TestCase

  test 'env empty' do
    ENV['AMP_RELEASE'] = nil
    System::Deploy.load_info!
    assert_equal nil, System::Deploy.info.release
  end

  test 'env not empty' do
    ENV['AMP_RELEASE'] = '2.0.0'
    System::Deploy.load_info!
    assert_equal '2.0.0', System::Deploy.info.release
  end

  test 'info is invalid' do
    ENV['AMP_RELEASE'] = '2.0.0'
    System::Deploy.load_info!
    assert_equal '2.0.0', System::Deploy.info.release

    System::Deploy.expects(:parse_deploy_info).raises(StandardError.new)
    System::Deploy.load_info!
    assert_equal '2.0.0', System::Deploy.info.release
  end

end
