require 'test_helper'

class ApiClassificationServiceTest < ActiveSupport::TestCase

  def setup
    @service = ApiClassificationService
  end

  def test_real_api?
    assert_not @service.test('https://echo-api.3scale.net').real_api?

    assert_not @service.test('http://echo-api.3scale.net').real_api?

    assert @service.test('https://api.github.com').real_api?
  end
end
