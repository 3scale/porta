require 'test_helper'

class BackendApiConfigTest < ActiveSupport::TestCase
  def setup
    @config = BackendApiConfig.new
  end

  def test_strip_slashes_from_private_endpoint
    @config.path = '/hello'
    assert_equal 'hello', @config.path

    @config.path = 'hello/my/name/is'
    assert_equal 'hello/my/name/is', @config.path

    @config.path = 'hello/my/name/is/'
    assert_equal 'hello/my/name/is', @config.path

    @config.path = '/hello/my/name/is/john/'
    assert_equal 'hello/my/name/is/john', @config.path
  end

  def test_path_field_must_be_a_path
    @config.path = 'https://example.com/hello'
    refute @config.valid?
    assert_match /must be a path/, @config.errors[:path].join('')
  end
end
