require 'test_helper'

class Onboarding::RequestFormTest < ActiveSupport::TestCase

  def test_path
    proxy = FactoryBot.build(:proxy)
    form = Onboarding::RequestForm.new(proxy)

    assert_nil form.path

    assert form.validate(path: nil)
    assert form.save

    assert proxy.persisted?

    assert_equal '/', proxy.api_test_path

    assert form.validate(path: 'some-path'), 'form is not valid'
    assert form.save, proxy.errors.full_messages.to_sentence
    assert_equal '/some-path', proxy.api_test_path
  end

  def test_api_base_url
    proxy = FactoryBot.build(:proxy)
    form = Onboarding::RequestForm.new(proxy)

    assert form.save

    form.api_base_url = base_url = 'https://invalid / url'
    assert_equal base_url, form.api_base_url

    refute form.save
  end

  def test_test_api!
    proxy = FactoryBot.build_stubbed(:proxy, sandbox_endpoint: 'http://staging.apicast.io')
    proxy.expects(:deploy!).returns(true)

    form = Onboarding::RequestForm.new(proxy)

    stub_request(:get, /staging.apicast.io/).to_return(status: 200, body: 'success')

    assert status = form.test_api!

    assert_nil status.error
    assert status.success?, 'test should succeed'
  end

  def test_path_without_slash
    proxy = FactoryBot.build(:proxy)
    form = Onboarding::RequestForm.new(proxy)
    assert_equal '', form.path_without_slash

    proxy.api_test_path = '/foo'
    form = Onboarding::RequestForm.new(proxy)
    assert_equal 'foo', form.path_without_slash
  end
end
