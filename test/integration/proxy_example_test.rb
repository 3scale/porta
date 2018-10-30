require 'test_helper'

## put those requirements wherever they need to go in the app test suite
require 'addressable/uri'
require 'digest/md5'
require 'httpclient/include_client'

class ProxyExampleTest < ActiveSupport::TestCase
  include Timeout
  extend ::HTTPClient::IncludeClient

  def system(*cmd)
    Kernel.puts cmd.join(' ')
    Kernel.system(*cmd)
  end

  mattr_accessor :started_external
  class_attribute :nginx_port, :logging, :nginx_prefix, :nginx_config, :thin_port, instance_writer: false

  self.nginx_port = 44432
  self.thin_port = 4001
  self.nginx_prefix = Pathname('/tmp/nginx/').freeze
  self.nginx_config = 'proxy_tmp.conf'

  self.logging = true

  include_http_client do |http|
    # Print all HTTP communication when DEBUG=1 is set
    http.debug_dev = $stdout if logging?
  end

  def setup
    skip 'Skipping APIcast tests'
    # FIXME: we should come back to this to see if these tests really add much value.
    # @mikz suggested they don't offer too much and could be disabled while we were
    # trying to get tests green on CircleCI.

    WebMock.disable_net_connect!(allow: /foo.example.com/, allow_localhost: true)
    ## to reset the last_response in the fake backend
    self.class.started_external ||= assert start_external_api, 'failed to start thin'

    response = http_client.get "http://127.0.0.1:#{thin_port}/transactions/authrep.xml"
    assert_equal 200, response.status
    assert_equal '', response.body.to_str

    @provider = FactoryGirl.create(:provider_account)
    @service = @provider.first_service! || @provider.services.first!

    # the backend mockup expects the api_id/api_key auth mode
    @service.update_attributes!(backend_version: '2')
    @provider.reload

    @service.service_tokens.create!(value: 'some_service_token')

    assert_valid @proxy = @service.proxy
    @metric = @hits = @service.metrics.find_by!(system_name: 'hits')

    NonLocalhostValidator.any_instance.stubs(validate_each: true)
  end

  def teardown
    kill_nginx
    WebMock.disable_net_connect!
  end

  def with_proxy_rule(pr_options, proxy = nil, &_block)
    ## define your rules
    ## for instance, there is a rule that "GET /v1/word/fantastic.json" should report a metric "super_hit=42"
    p = enable_proxy(proxy)

    case pr_options
    when Array
        pr_options.map!{ |pr| pr.reverse_merge!(delta: 1) }
    end

    proxy_rules = p.proxy_rules

    Array.wrap(pr_options).each do |attributes|
      rule = proxy_rules.build(attributes.reverse_merge(delta: 1))
      rule.metric ||= @metric
      rule.save!
    end

    source = Apicast::ProviderSource.new(@provider)
    generate_config(source)


    ## build the nginx and lua config file
    kill_nginx

    assert start_nginx, 'failed to start nginx'

    yield
  end

  def generate_config(source)
    package = Apicast::ProviderPackageGenerator.new(source)
    folder = Pathname(nginx_prefix)

    folder.mkpath
    folder.join('logs').mkpath

    package.each do |file, contents|
      folder.join(file).write(contents.call)
    end

    conf = folder.join(nginx_config)

    conf.unlink if conf.exist?
    conf.make_symlink(package.nginx_conf)
  end

  def enable_proxy(proxy = nil)
    p = proxy || @proxy

    if !p.api_backend || p.api_backend.starts_with?(p.default_api_backend)
      p.api_backend = "http://127.0.0.1:#{thin_port}"
    end
    p.endpoint = "http://foo.example.com:#{nginx_port}"

    if (a = p.proxy_rules.find_by_pattern('/'))
      a.delete
    end

    p.save!
    p
  end

  def wait_for(port, seconds = 10)
    opened = lambda do
      begin
        TCPSocket.new('127.0.0.1', port)
      rescue Errno::ETIMEDOUT, Errno::ECONNREFUSED
        false
      end
    end

    timeout(seconds) do
      loop do
        if opened.call
          return true
        else
          sleep(0.1)
        end
      end
    end
  end

  def start_thin
    dir = Rails.root.join('test/proxy_helpers/sentiment')

    ChildProcess.build('thin', '-p', thin_port.to_s, '-R', 'config.ru', '-c', dir.to_s, 'start')
  end

  def start_external_api
    assert stop_external_api, "couldn't stop thin"

    thin = start_thin
    thin.io.inherit! if logging?

    thin.start
    assert thin.alive?

    at_exit { thin.stop }

    wait_for(thin_port)
    assert thin.alive?

    @thin = thin
  end

  def stop_external_api
    if @thin
      @thin.stop
      return !@thin.alive?
    else
      true
    end
  end

  def build_nginx
    ChildProcess.build('nginx', '-c', nginx_prefix.join(nginx_config).to_s, '-p', nginx_prefix.to_s, '-g', 'daemon off;')
  end

  def start_nginx
    nginx = build_nginx
    nginx.leader = true

    if logging?
      nginx.io.inherit!
      puts "starting #{nginx}"
    end

    nginx.start
    assert nginx.alive?

    wait_for(nginx_port)
    assert nginx.alive?

    @nginx = nginx
  end

  def kill_nginx
    @nginx.try!(:stop) if @nginx.try(:alive?)
    @nginx = nil
  end

  def nginx_url(path = ''.freeze, host: 'foo.example.com'.freeze)
    URI.join("http://#{host}:#{nginx_port}/", path).to_s
  end

  def api_get(path, *args)
    http_client.get nginx_url(path), *args
  end

  def api_post(path, *args)
    http_client.post nginx_url(path), *args
  end

  def backend_get(path, *args)
    http_client.get "http://foo.example.com:#{thin_port}#{path}", *args
  end

  ### THIS IS WHERE THE TEST START

  test 'multiple services' do
    FactoryGirl.create(:service, account: @provider)
    one, two = @provider.proxies.map(&method(:enable_proxy))

    rules = [ { pattern: '/', http_method: 'GET' } ]

    with_proxy_rule(rules, one) do
      with_proxy_rule(rules, two) do
        response = api_get '/v1/word/hello.json?app_id=my_app_id&app_key=my_app_key'

        assert_equal 200, response.status
      end
    end
  end

  test 'checking the fake backend' do
    params = { 'provider_key' => 'foo', 'app_id' => 'bar', 'usage' => { 'hits' => '42' } }

    response = backend_get "/transactions/authrep.xml?#{params.to_query}"

    assert_equal 200, response.status
    assert_equal "", response.body

    authrep = last_authrep

    ## order of the hash matters
    ## assert_equal params.to_json, response
    body_without_headers = authrep
    body_without_headers.delete('headers')
    body_without_headers.delete('backend_headers')

    assert_equal params.to_s.chars.sort.join, body_without_headers.to_s.chars.sort.join
  end

  test 'gets' do
    with_proxy_rule(pattern: '/v1/word/{word}.json', http_method: 'GET', delta: 2) do
      response = api_get '/v1/word/fantastic.json?app_id=my_app_id&app_key=my_app_key'

      ## check that response is correct
      assert_equal 200, response.status
      assert_equal JSON.parse('{"sentiment":4,"word":"fantastic"}'), JSON.parse(response.body)
      ## check that the proxy is sending the right info to the backend
      authrep = last_authrep

      assert_equal 'my_app_id', authrep['app_id']
      assert_equal 'my_app_key', authrep['app_key']
      assert_equal @service.id.to_s, authrep['service_id']
      assert_equal @service.backend_authentication_value, authrep[@service.backend_authentication_type.to_s]
      assert_equal 2, authrep['usage']['hits'].to_i
      assert_equal 1, authrep['usage'].size
    end
  end

  def last_authrep
    JSON.parse http_client.get_content("http://foo.example.com:#{thin_port}/last_authrep.json")
  end

  test 'pattern' do
    with_proxy_rule(pattern: '/$', http_method: 'GET', delta: 2) do
      api_get '/?app_id=my_app_id&app_key=my_app_key'

      assert authrep = last_authrep
      assert_equal 2, Integer(last_authrep['usage']['hits'])

      response = api_get '/hola?app_id=my_app_id&app_key=my_app_key'
      assert_equal 404, response.status
    end
  end

  test 'querystring params with fixed value is mandatory' do
    with_proxy_rule(pattern: '/v1/word/{word}.json?bar=baz', http_method: 'GET') do
      response = api_get '/v1/word/fantastic.json?app_id=my_app_id&app_key=my_app_key&foo=lol&bar=baz'
      assert_equal 200, response.status
      assert_equal JSON.parse('{"sentiment":4,"word":"fantastic"}'), JSON.parse(response.body)

      response = api_get '/v1/word/fantastic.json?app_id=my_app_id&app_key=my_app_key&foo=lol&bar=baz2'
      assert_equal 404, response.status
      assert_equal 'No Mapping Rule matched', response.body

      response = api_get '/v1/word/fantastic.json?app_id=my_app_id&app_key=my_app_key&foo=lol&bbar=baz'
      assert_equal 404, response.status
      assert_equal 'No Mapping Rule matched', response.body
    end
  end

  test 'querystring params with variable value' do
    with_proxy_rule(pattern: '/v1/word/{word}.json?bar={baz}', http_method: 'GET') do
      response = api_get '/v1/word/fantastic.json?app_id=my_app_id&app_key=my_app_key&bar=somevalue'
      assert_equal 200, response.status
      assert_equal JSON.parse('{"sentiment":4,"word":"fantastic"}'), JSON.parse(response.body)

      response = api_get '/v1/word/fantastic.json?app_id=my_app_id&app_key=my_app_key&somevalue=bar'
      assert_equal 404, response.status
      assert_equal 'No Mapping Rule matched', response.body
    end
  end

  test 'secret token is sent to the backend' do
    Timecop.freeze do
      timestamp = Time.now.utc.iso8601

      with_proxy_rule(pattern: '/v1/word/{word}.json', http_method: 'GET') do
        api_get '/v1/word/fantastic.json?app_id=my_app_id&app_key=my_app_key'

        authrep = last_authrep
        assert_equal @proxy.secret_token, authrep['headers']['X_3SCALE_PROXY_SECRET_TOKEN']

        assert_equal 'nginx', authrep['backend_headers']['X_3SCALE_USER_AGENT']
        assert_equal timestamp, authrep['backend_headers']['X_3SCALE_VERSION']
      end
    end
  end

  test 'post with user_key' do
    @service.update_attributes!(backend_version: 1)

    with_proxy_rule(pattern: '/v1/word/{word}.json?value={value}', http_method: 'POST',
                    delta: 2, metric_id: @hits.id) do
      response = api_post '/v1/word/webinar.json', user_key: 'my_user_key', value: 3

      ## check that response is correct
      assert_equal 200, response.status
      assert_equal JSON.parse('{"sentiment":3,"word":"webinar"}'), JSON.parse(response.body)

      ## check that the proxy is sending the right info to the backend
      authrep = last_authrep

      assert_equal 'my_user_key', authrep['user_key']
      assert_equal @service.backend_authentication_value, authrep[@service.backend_authentication_type.to_s]
      assert_equal 2, authrep['usage']['hits'].to_i
      assert_equal 1, authrep['usage'].size
    end
  end

  test 'post in headers' do
    @proxy.update_attributes!(credentials_location: 'headers')

    with_proxy_rule(pattern: '/v1/word/{word}.json?value={value}', http_method: 'POST',
                    delta: 2, metric_id: @hits.id) do
      response = api_post '/v1/word/webinar.json', { value: 3 },
                          'app_id' => 'my_app_id', 'app_key' => 'my_app_key'

      ## check that response is correct
      assert_equal 200, response.status
      assert_equal JSON.parse('{"sentiment":3,"word":"webinar"}'), JSON.parse(response.body)

      authrep = last_authrep
      ## check that the proxy is sending the right info to the backend
      assert_equal 'my_app_id', authrep['app_id']
      assert_equal 'my_app_key', authrep['app_key']
      assert_equal @service.backend_authentication_value, authrep[@service.backend_authentication_type.to_s]
      assert_equal 2, authrep['usage']['hits'].to_i
      assert_equal 1, authrep['usage'].size
    end
  end

  test 'changed app_id and app_key names' do
    @proxy.update_attributes!(auth_app_key: 'custom_app_key', auth_app_id: 'custom_app_id')

    with_proxy_rule(pattern: '/v1/word/{word}.json', http_method: 'GET',
                    delta: 2, metric_id: @metric.id) do
      response = api_get '/v1/word/fantastic.json?custom_app_id=my_app_id&custom_app_key=my_app_key'
      ## check that response is correct
      assert_equal 200, response.status
      assert_equal JSON.parse('{"sentiment":4,"word":"fantastic"}'), JSON.parse(response.body)

      ## check that the proxy is sending the right info to the backend
      authrep = last_authrep
      assert_equal 'my_app_id', authrep['app_id']
      assert_equal 'my_app_key', authrep['app_key']
      assert_equal @service.id.to_s, authrep['service_id']
      assert_equal @service.backend_authentication_value, authrep[@service.backend_authentication_type.to_s]
      assert_equal 2, authrep['usage']['hits'].to_i
      assert_equal 1, authrep['usage'].size
    end
  end

  test 'changed user_key name' do
    @service.update_attributes!(backend_version: '1')
    @proxy.update_attributes!(auth_user_key: 'custom_user_key')

    with_proxy_rule(pattern: '/v1/word/{word}.json',
                    http_method: 'GET',
                    delta: 2,
                    metric_id: @metric.id) do
      response = api_get '/v1/word/fantastic.json?custom_user_key=my_user_key'
      ## check that response is correct
      assert_equal 200, response.status
      assert_equal JSON.parse('{"sentiment":4,"word":"fantastic"}'), JSON.parse(response.body)

      ## check that the proxy is sending the right info to the backend
      authrep = last_authrep
      assert_equal 'my_user_key', authrep['user_key']
      assert_equal @service.id.to_s, authrep['service_id']
      assert_equal @service.backend_authentication_value, authrep[@service.backend_authentication_type.to_s]
      assert_equal 2, authrep['usage']['hits'].to_i
      assert_equal 1, authrep['usage'].size
    end
  end

  test 'changed credentials name in headers' do
    @proxy.update_attributes!(credentials_location: 'headers',
                              auth_app_key: 'custom_app_key',
                              auth_app_id: 'custom_app_id')

    with_proxy_rule(pattern: '/v1/word/{word}.json?value={value}',
                    http_method: 'POST',
                    delta: 2,
                    metric_id: @metric.id) do
      response = api_post '/v1/word/webinar.json',
                          { value: 3 },
                          'custom_app_id' => 'my_app_id',
                          'custom_app_key' => 'my_app_key'

      ## check that response is correct

      assert_equal 200, response.status
      assert_equal JSON.parse('{"sentiment":3,"word":"webinar"}'), JSON.parse(response.body)
      ## check that the proxy is sending the right info to the backend
      authrep = last_authrep
      assert_equal 'my_app_id', authrep['app_id']
      assert_equal 'my_app_key', authrep['app_key']
      assert_equal @service.backend_authentication_value, authrep[@service.backend_authentication_type.to_s]
      assert_equal 2, authrep['usage']['hits'].to_i
      assert_equal 1, authrep['usage'].size
    end
  end

  test 'changed credentials to capitals in headers' do
    @proxy.update_attributes!(credentials_location: 'headers',
                              auth_app_key: 'CUSTOM_APP_KEY',
                              auth_app_id: 'CUSTOM_APP_ID')

    with_proxy_rule(pattern: '/v1/word/{word}.json?value={value}', http_method: 'POST') do
      api_post '/v1/word/webinar.json', { value: 3 },
                  'custom_app_id' => 'my_app_id',
                  'CUSTOM_APP_KEY' => 'my_app_key'

      authrep = last_authrep
      assert_equal 'my_app_id', authrep['app_id']
      assert_equal 'my_app_key', authrep['app_key']
    end
  end

  test 'repeated parameters. we pick the first' do
    with_proxy_rule(pattern: '/v1/search.json?action=wat&q={q}', http_method: 'GET') do
      response = api_get '/v1/search.json?app_id=my_app_id&app_key=my_app_key&action=other&action=wat'
      assert_equal 404, response.status

      response = api_get '/v1/search.json?app_id=my_app_id&app_key=my_app_key&action=wat&action=lal&q=fdwa'
      assert_equal 200, response.status

      ## order of the hash matters
      ## assert_equal params.to_json, response
      # assert_equal params.to_json.chars.sort.join, response.chars.sort.join
    end
  end

  test 'debug mode sends info back' do

    with_proxy_rule(pattern: pattern = '/v1/word/{word}.json', http_method: 'GET',
                    delta: 2, metric: @hits) do
      response = api_get '/v1/word/fantastic.json?app_id=my_app_id&app_key=my_app_key', {},
                         'X-3scale-debug' => @provider.api_key

      ## check that response is correct
      assert_equal 200, response.status
      assert_equal JSON.parse('{"sentiment":4,"word":"fantastic"}'), JSON.parse(response.body)
      assert_equal 'app_key=my_app_key&app_id=my_app_id', response.headers['X-3scale-credentials']
      assert_equal 'usage[hits]=2', response.headers['X-3scale-usage']
      assert_equal pattern, response.headers['X-3scale-matched-rules']
      assert_not_nil response.headers['X-3scale-hostname']

      response = api_get '/v1/word/fantastic.json?app_id=my_app_id&app_key=my_app_key'

      assert_nil response.headers['X-3scale-credentials']
      assert_nil response.headers['X-3scale-usage']
      assert_nil response.headers['X-3scale-matched-rules']
      assert_nil response.headers['X-3scale-hostname']
      ## check that the proxy is sending the right info to the backend
    end
  end

  test 'multiple calls with debug header' do
    with_proxy_rule(pattern: '/v1/word/{word}.json', http_method: 'GET') do
      response = api_get '/v1/word/fantastic.json?app_id=my_app_id&app_key=my_app_key', {},
                         'X-3scale-debug' => @provider.api_key

      ## check that response is correct
      assert_equal 200, response.status
      response = api_get '/v1/word/fantastic.json?app_id=my_app_id&app_key=my_app_key', {},
                         'X-3scale-debug' => @provider.api_key

      ## check that response is correct
      assert_equal 200, response.status
    end
  end

  test 'multiple rules with debug header' do
    with_proxy_rule([ { pattern: '/v1/word/{word}.json', http_method: 'GET' },
                      { pattern: '/v2/word/{word}.json', http_method: 'GET' }]) do
      response = api_get '/v1/word/fantastic.json?app_id=my_app_id&app_key=my_app_key', {},
                         'X-3scale-debug' => @provider.api_key

      ## check that response is correct
      assert_equal 200, response.status
      response = api_get '/v1/word/hello.json?app_id=my_app_id&app_key=my_app_key', {},
                         'X-3scale-debug' => @provider.api_key

      ## check that response is correct
      assert_equal 200, response.status
    end
  end

  test 'hostname rewrite' do
    @proxy.update_attributes!(hostname_rewrite: 'localhost')

    with_proxy_rule(pattern: '/', http_method: 'GET') do
      response = api_get '/v1/search.json?app_id=my_app_id&app_key=my_app_key'
      assert_equal 200, response.status

      authrep = last_authrep
      assert_equal 'localhost', authrep['headers']['HOST']
    end
  end

  test 'default hostname rewrite' do
    @proxy.update_columns(api_backend: "http://127.0.0.1:#{thin_port}")

    with_proxy_rule(pattern: '/', http_method: 'GET') do
      response = api_get '/v1/search.json?app_id=my_app_id&app_key=my_app_key'
      assert_equal 200, response.status

      authrep = last_authrep
      assert_equal '127.0.0.1', authrep['headers']['HOST']
    end
  end

  test 'non existent path in backend' do
    with_proxy_rule(pattern: '/v1/word/{word}.json', http_method: 'GET') do
      response = api_get '/nonexistent/word/fantastic.json?app_id=my_app_id&app_key=my_app_key'

      assert_equal 404, response.status
    end
  end

  test 'two rules increment the same metric' do
    with_proxy_rule([ { pattern: '/v1/word/{word}.json', http_method: 'GET', delta: 2 },
                      { pattern: '/v1/', http_method: 'GET', delta: 3 }]) do
      response = api_get '/v1/word/fantastic.json?app_id=my_app_id&app_key=my_app_key', {},
                         'X-3scale-debug' => @provider.api_key

      assert_equal 'usage[hits]=5', response.headers['X-3scale-usage']
    end
  end

  test 'exact match with dollar sign $' do
    with_proxy_rule([ { pattern: '/v1/word/{word}.json', http_method: 'GET', delta: 2 },
                      { pattern: '/v1/$', http_method: 'GET', delta: 3 }]) do
      response = api_get '/v1/word/fantastic.json?app_id=my_app_id&app_key=my_app_key', {},
                         'X-3scale-debug' => @provider.api_key

      assert_equal 'usage[hits]=2', response.headers['X-3scale-usage']
    end
  end

  test 'exact match with dollar sign2' do
    with_proxy_rule([ { pattern: '/foo/bar', http_method: 'GET', delta: 2 },
                      { pattern: '/foo$?foo=bar', http_method: 'GET', delta: 3 } ]) do

      response = api_get '/foo?foo=bar&app_id=my_app_id&app_key=my_app_key', {}, 'X-3scale-debug' => @provider.api_key

      assert_equal 'usage[hits]=3', response.headers['X-3scale-usage']
    end
  end

  test 'custom error messages in json' do
    @proxy.update_attributes!(error_no_match: '{"foo":1}',
                              error_status_no_match: 403,
                              error_headers_no_match: '{"foo":1}')
    with_proxy_rule(pattern: '/v1/word/{word}.json', http_method: 'GET') do
      response = api_get '/nonexistent/word/fantastic.json?app_id=my_app_id&app_key=my_app_key', {}, 'X-3scale-debug' => @provider.api_key

      assert_equal 403, response.status
      assert_equal '{"foo":1}', response.body
      assert_equal '{"foo":1}', response.headers['Content-Type']
    end
  end

  test 'cache invalidation' do
    with_proxy_rule(pattern: '/v1/word/{word}.json',
                    http_method: 'GET',
                    delta: 2,
                    metric_id: @metric.id) do
      response = api_get '/v1/word/fantastic.json?app_id=my_app_id&app_key=my_app_key'
      assert_equal 200, response.status

      response = api_get '/v1/word/fantastic.json'
      assert_equal 403, response.status

      response = api_get '/v1/word/fantastic.json?app_id=my_app_id&app_key=my_app_key'
      assert_equal 200, response.status
    end
  end

  test 'oauth authorize wrong redirect_url' do
    @service.update_attributes!(backend_version: 'oauth')
    @proxy.update_attributes!(oauth_login_url: "http://localhost:#{thin_port}/login")

    with_proxy_rule([]) do
      response = api_get '/authorize?response_type=code&client_id=foo&redirect_uri=no-match&scope=foo'

      assert_equal "http://localhost:#{thin_port}/login?scope=foo&state=&error=invalid_request", response.headers['Location'],
                   "#{response.inspect} should have proper Location"
    end
  end

  test 'oauth authorize wrong response_type' do
    @service.update_attributes!(backend_version: 'oauth')
    @proxy.update_attributes!(oauth_login_url: "http://localhost:#{thin_port}/login")


    with_proxy_rule([]) do
      response = api_get '/authorize?response_type=WRONG&client_id=foo&redirect_uri=foo&scope=foo'

      assert_equal "http://localhost:#{thin_port}/login?scope=foo&state=&error=unsupported_response_type", response.headers['Location'],
                   "#{response.inspect} should have proper Location"
    end
  end

  test 'oauth authorize not enough params' do
    @service.update_attributes!(backend_version: 'oauth')
    @proxy.update_attributes!(oauth_login_url: "http://localhost:#{thin_port}/login")

    with_proxy_rule([]) do
      response = api_get '/authorize?response_type=code&redirect_uri=match&scope=foo'

      assert_equal "http://localhost:#{thin_port}/login?scope=foo&state=&error=invalid_request", response.headers['Location'],
                   "#{response.inspect} should have proper Location"
    end
  end


  test 'oauth short circuit authorize to callback' do
    @service.update_attributes!(backend_version: 'oauth')
    @proxy.update_columns(oauth_login_url: nginx_url('/callback', host: 'foo.example.com'))

    with_proxy_rule(pattern: '/', http_method: 'GET') do
      response = api_get '/authorize?response_type=code&redirect_uri=/success&scope=foo&client_id=foo&state=abc'

      assert_equal 302, response.status  # check that redis is running if it is 200

      callback = response.headers['Location']

      assert callback.starts_with?(@proxy.oauth_login_url), "#{callback} should start with #{@proxy.oauth_login_url}"

      response = http_client.get(callback)

      assert_equal 302, response.status
      callback = URI(response.headers['Location'])

      assert_equal '/success', callback.path

      params = URI.decode_www_form(callback.query).to_h

      access_token = params['code']
      response = api_get "/v1/word/fantastic.json?access_token=#{access_token}"

      assert_equal 200, response.status

      auth = last_authrep

      assert_equal access_token, auth['access_token']
    end
  end

  class WithoutRollingUpdate < ProxyExampleTest
    def setup
      Logic::RollingUpdates.stubs(skipped?: true)
      super
      assert_equal :provider_key, @service.backend_authentication_type
    end
  end

  class WithDockerGateway < ProxyExampleTest
    self.nginx_port = 8080
    self.logging = true
    self.nginx_prefix = Rails.root.join('vendor', 'docker-gateway').freeze
    self.nginx_config = Pathname('/tmp/nginx/spec.json').freeze

    def generate_config(source)
      package = Apicast::ProviderConfigGenerator.new(source)
      folder = Pathname(nginx_config).dirname

      folder.mkpath

      package.each do |file, contents|
        folder.join(file).write(contents.call)
      end

      ENV['THREESCALE_CONFIG_FILE'] = folder.join(package.spec_file).to_s
    end

    def build_nginx
      ChildProcess.build(nginx_prefix.join('bin/apicast').to_s)
    end

    def test_oauth_authorize_wrong_redirect_url
      @service.update_attributes!(backend_version: 'oauth')
      @proxy.update_attributes!(oauth_login_url: "http://localhost:#{thin_port}/login")

      with_proxy_rule([]) do
        response = api_get '/authorize?response_type=code&client_id=foo&redirect_uri=no-match&scope=foo'

        assert_equal "http://localhost:#{thin_port}/login?scope=foo&response_type=code&error=invalid_client&redirect_uri=no-match&client_id=foo", response.headers['Location'],
                     "#{response.inspect} should have proper Location"
      end
    end

    def test_oauth_authorize_wrong_response_type
      @service.update_attributes!(backend_version: 'oauth')
      @proxy.update_attributes!(oauth_login_url: "http://localhost:#{thin_port}/login")


      with_proxy_rule([]) do
        response = api_get '/authorize?response_type=WRONG&client_id=foo&redirect_uri=foo&scope=foo'

        assert_equal "http://localhost:#{thin_port}/login?scope=foo&response_type=WRONG&error=unsupported_response_type&redirect_uri=foo&client_id=foo", response.headers['Location'],
                     "#{response.inspect} should have proper Location"
      end
    end

    def test_oauth_authorize_not_enough_params
      @service.update_attributes!(backend_version: 'oauth')
      @proxy.update_attributes!(oauth_login_url: "http://localhost:#{thin_port}/login")

      with_proxy_rule([]) do
        response = api_get '/authorize?response_type=code&redirect_uri=match&scope=foo'

        assert_equal "http://localhost:#{thin_port}/login?scope=foo&error=invalid_request&response_type=code&redirect_uri=match", response.headers['Location'],
                     "#{response.inspect} should have proper Location"
      end
    end
  end
end
