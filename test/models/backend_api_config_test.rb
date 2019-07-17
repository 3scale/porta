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

  def test_path
    @config.save!
    @config.update_columns(path: 'https://example.com/hello')
    @config.reload
    refute @config.valid?
  end
end
