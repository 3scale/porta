require 'test_helper'

class ConfigPathTest < ActiveSupport::TestCase
  test 'includes initial slash in path if not present' do
    config_path = ConfigPath.new('hello')
    assert_equal '/hello', config_path.path

    config_path = ConfigPath.new('/hello')
    assert_equal '/hello', config_path.path
  end

  test '#empty? returns true if path is equal /' do
    assert ConfigPath.new('/').empty?
  end

  test '#empty? returns false if path is not equal /' do
    refute ConfigPath.new('/somepath').empty?
  end

  test '#to_regex returns "/.*" if path is not informed' do
    assert_equal '/.*', ConfigPath.new('/').to_regex
  end

  test '#to_regex returns the regex for the path if it is informed' do
    assert_equal '/some/path/.*|/some/path/?', ConfigPath.new('/some/path').to_regex
  end
end
