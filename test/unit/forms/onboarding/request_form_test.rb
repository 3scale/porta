require 'test_helper'

class Onboarding::RequestFormTest < ActiveSupport::TestCase
  setup do
    @proxy = FactoryBot.build(:proxy, service: FactoryBot.create(:service))
    @form = Onboarding::RequestForm.new(proxy)
  end

  attr_reader :proxy, :form

  test 'path' do
    assert_nil form.path

    assert form.validate(path: nil)
    assert form.save

    assert proxy.persisted?

    assert_equal '/', proxy.api_test_path

    assert form.validate(path: 'some-path'), 'form is not valid'
    assert form.save, proxy.errors.full_messages.to_sentence
    assert_equal '/some-path', proxy.api_test_path
  end

  test 'api_base_url' do
    assert form.save

    form.api_base_url = base_url = 'https://invalid / url'
    assert_equal base_url, form.api_base_url

    refute form.save
  end

  test '#uri' do
    proxy.save!
    proxy.update(api_backend: 'http://echo-api.net')
    form = Onboarding::RequestForm.new(proxy)
    assert_equal 'http://echo-api.net/', form.uri

    form.path = '/'
    assert_equal 'http://echo-api.net/', form.uri

    form.path = '/hello'
    assert_equal 'http://echo-api.net/hello', form.uri

    proxy.update(api_backend: 'http://echo-api.net/api')
    form = Onboarding::RequestForm.new(proxy)
    assert_equal 'http://echo-api.net/api/', form.uri

    form.path = '/hello'
    assert_equal 'http://echo-api.net/api/hello', form.uri

    proxy.backend_api_configs.delete_all
    form = Onboarding::RequestForm.new(proxy.reload)
    refute proxy.reload.api_backend
    refute form.uri
  end

  test 'test_api!' do
    proxy.save!
    proxy.update! sandbox_endpoint: 'http://staging.apicast.io'

    ProxyDeploymentService.any_instance.expects(:deploy).returns(true)

    form = Onboarding::RequestForm.new(proxy)

    stub_request(:get, /staging.apicast.io/).to_return(status: 200, body: 'success')

    assert status = form.test_api!

    assert_nil status.error
    assert status.success?, 'test should succeed'
  end

  test 'path_without_slash' do
    assert_equal '', form.path_without_slash

    proxy.api_test_path = '/foo'
    form = Onboarding::RequestForm.new(proxy)
    assert_equal 'foo', form.path_without_slash
  end
end
