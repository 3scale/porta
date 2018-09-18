require 'test_helper'

class ApiClassificationServiceTest < ActiveSupport::TestCase

  def setup
    @service = ApiClassificationService
  end

  def test_real_api?
    refute @service.test('https://hello-world-api.3scale.net').real_api?

    refute @service.test('http://hello-world-api.3scale.net').real_api?

    refute @service.test('https://echo-api.3scale.net').real_api?

    assert @service.test('https://api.github.com').real_api?
  end
end
