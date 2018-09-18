require 'test_helper'

class ThreeScale::Middleware::DevDomainTest < ActiveSupport::TestCase

  def test_env_same
    env = {}
    res = [200, {}, [Object.new.freeze]]

    app = lambda do |e|
      assert_equal env, e
      assert_equal env.object_id, e.object_id

      res
    end

    middleware = ThreeScale::Middleware::DevDomain.new(app)

    assert_equal res, middleware.call(env)
  end

  def test_override
    env = {
      'HTTP_HOST' => 'api.foo.example.com',
      'HTTP_X_FORWARDED_HOST' => 'foobar.example.com'
    }
    res = [200, {}, [Object.new.freeze]]
    app = lambda do |e|
      assert_equal({
                     'HTTP_HOST' => 'api.example.net',
                     'HTTP_X_FORWARDED_HOST' => 'foobar.example.com,api.example.net',
                     'HTTP_X_FORWARDED_FOR_DOMAIN' => 'api.foo.example.com'
                   }, e)
      assert_equal env.object_id, e.object_id

      res
    end

    middleware = ThreeScale::Middleware::DevDomain.new(app, /\.foo\.example.com$/, '.example.net')

    assert_equal res, middleware.call(env)
  end

  def test_redirect
    app = lambda do |env|
      [ 301, {'Location' => 'http://api.foo.example.com/path' }, [] ]
    end
    middleware = ThreeScale::Middleware::DevDomain.new(app, /\.foo\./)

    status, headers, _ = middleware.call({'HTTP_HOST' => 'api.foo.example.com'})

    assert_equal 301, status
    assert_equal 'http://api.foo.example.com/path', headers.fetch('Location')
  end

  def test_default_pattern_and_replacement
    middleware = ThreeScale::Middleware::DevDomain.new(proc { })

    assert_equal /\.preview\d+\./, middleware.pattern
    assert_equal '.', middleware.replacement
  end
end
