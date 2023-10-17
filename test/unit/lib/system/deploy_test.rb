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

  test 'parse deploy info' do
    File.open('.deploy_info_test', 'w') do |file|
      file << '{"revision": "rev", "release": "rel"}'
      file.flush

      deploy_info = System::Deploy.parse_deploy_info(file.path)
      assert_equal 'rev', deploy_info['revision']
      assert_equal 'rel', deploy_info['release']
    end
  end

  test 'call' do
    System::Deploy.load_info!
    response = System::Deploy.call(nil)
    assert_equal 200, response[0]
    assert_equal 'application/json', response[1]['Content-Type']
    assert_equal '2.x', JSON.parse(response[2].first)['release']
  end

  class OnpremisesDeployTest < ActiveSupport::TestCase
    setup do
      ThreeScale.config.stubs(onpremises: true)
      System::Deploy.load_info! ActiveSupport::JSON.decode('{"revision": "2.13-stable", "release": "2.13"}')
    end

    test 'onpremises release has a major and minor version' do
      assert_equal '2', System::Deploy.info.major_version
      assert_equal '13', System::Deploy.info.minor_version
    end

    test 'docs url point to onpremises product docs' do
      assert_equal 'red_hat_3scale_api_management/2.13', System::Deploy.info.docs_version
    end
  end

  class SaasDeployTest < ActiveSupport::TestCase
    setup do
      ThreeScale.config.stubs(onpremises: false)
      System::Deploy.load_info! ActiveSupport::JSON.decode('{"revision": "alpha", "release": "alpha"}')
    end

    test 'custom release from .deploy_info is ignored' do
      assert_equal '2', System::Deploy.info.major_version
      assert_equal 'x', System::Deploy.info.minor_version
    end

    test 'docs url point to SaaS product docs' do
      assert_equal 'red_hat_3scale/2-saas', System::Deploy.info.docs_version
    end
  end

  class RhoamDeployTest < ActiveSupport::TestCase
    setup do
      ThreeScale.config.stubs(onpremises: true)
      System::Deploy.load_info! ActiveSupport::JSON.decode('{"revision": "2.x-mas", "release": "RHOAM"}')
    end

    test 'RHOAM release has only one segment' do
      assert_equal 'RHOAM', System::Deploy.info.major_version
      assert_nil System::Deploy.info.minor_version
    end

    test 'docs url point to SaaS product docs' do
      assert_equal 'red_hat_3scale/2-saas', System::Deploy.info.docs_version
    end
  end

  class InvalidInfoTest < ActiveSupport::TestCase
    setup do
      System::Deploy.load_info! 'invalid-data'
    end

    teardown do
      System::Deploy.load_info!
    end

    test 'load invalid info' do
      info = System::Deploy.info

      assert info.is_a? System::Deploy::InvalidInfo
      assert_nil info.release
    end
  end

end
