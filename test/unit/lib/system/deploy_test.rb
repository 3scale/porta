# frozen_string_literal: true

require 'test_helper'

class DeployTest < ActiveSupport::TestCase
  test 'default release is 2.x' do
    System::Deploy.load_info!
    assert_equal '2.x', System::Deploy.info.release
  end

  test 'minor and major version taken from default release' do
    System::Deploy.load_info!
    assert_equal '2', System::Deploy.info.major_version
    assert_equal 'x', System::Deploy.info.minor_version
  end

  test 'custom release' do
    path = Rails.root.join('test', 'fixtures', 'deploy_info').expand_path
    System::Deploy.load_info! ActiveSupport::JSON.decode(path.read)

    assert_equal '4', System::Deploy.info.major_version
    assert_equal '5', System::Deploy.info.minor_version
  end
end
