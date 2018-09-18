require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class BackendClient::ConnectionTest < ActiveSupport::TestCase
  include TestHelpers::FakeWeb

  def setup
    @connection = BackendClient::Connection.new(:host => 'backend.example.org')
  end

  # TODO: test connection errors

  test 'sends get request without params to the backend' do
    ::FakeWeb.register_uri(:get, 'http://backend.example.org/stuff.xml', :body => '<stuff/>')
    @connection.get('/stuff.xml')

    assert_equal 'GET',        FakeWeb.last_request.method
    assert_equal '/stuff.xml', FakeWeb.last_request.path
  end

  test 'sends get request with one param to the backend' do
    ::FakeWeb.register_uri(:get, 'http://backend.example.org/stuff.xml?type=widget', :body => '<stuff/>')
    @connection.get('/stuff.xml', :type => 'widget')

    assert_equal 'GET',                    FakeWeb.last_request.method
    assert_equal '/stuff.xml?type=widget', FakeWeb.last_request.path
  end

  test 'sends get request with many params to the backend' do
    ::FakeWeb.register_uri(:get, 'http://backend.example.org/stuff.xml?quantity=lot&type=widget',
                         :body => '<stuff/>')

    @connection.get('/stuff.xml', :type => 'widget', :quantity => 'lot')

    assert_equal 'GET',                                 FakeWeb.last_request.method
    assert_equal '/stuff.xml?quantity=lot&type=widget', FakeWeb.last_request.path
  end

  test 'escapes params in a requests' do
    ::FakeWeb.register_uri(:get, 'http://backend.example.org/stuff.xml?type=atomic+bomb',
                         :body => '<stuff/>')

    @connection.get('/stuff.xml', :type => 'widget', :type => 'atomic bomb')

    assert_equal 'GET',                           FakeWeb.last_request.method
    assert_equal '/stuff.xml?type=atomic+bomb', FakeWeb.last_request.path
  end

  test 'sends post request to the backend' do
    ::FakeWeb.register_uri(:post, 'http://backend.example.org/stuff.xml', :body => '')
    @connection.post('/stuff.xml', :type => 'warpdrive')

    assert_equal 'POST',           FakeWeb.last_request.method
    assert_equal 'type=warpdrive', FakeWeb.last_request.body.to_s
  end

  test 'loads configuration from a file' do
    BackendClient.stubs(config: { host: 'backend.test.org:1234'})

    connection = BackendClient::Connection.new
    assert_equal 'backend.test.org:1234', connection.host
  end

  test 'retries the calls' do
    FakeWeb.register_uri(:post, 'http://backend.example.org/stuff.xml',
                       [{:body => "Post not found",  :status => ["404", "Not Found"]},
                        {:body => "Stuff not found",  :status => ["404", "Not Found"]},
                        {:body => "Stuff found.", :status => ["200", "OK"]}
    ])

    BackendClient::Request.any_instance.expects(:failure).twice
    assert_equal 'Stuff found.', @connection.post('/stuff.xml')
  end

  test 'sends airbrake when of retries too much' do
    FakeWeb.register_uri(:post, 'http://backend.example.org/stuff.xml',
                       [{:body => "Post not found",  :status => ["404", "Not Found"]},
                        {:body => "Stuff not found",  :status => ["404", "Not Found"]},
                        {:body => "Stuff not found",  :status => ["404", "Not Found"]},
                        {:body => "Stuff not found",  :status => ["404", "Not Found"]},
                        {:body => "Stuff not found",  :status => ["404", "Not Found"]},
                        {:body => "Stuff found.", :status => ["200", "OK"]}
    ])

    BackendClient::Request.any_instance.expects(:failure).times(5)

    System::ErrorReporting.expects(:report_error)
    assert_raise(RestClient::ResourceNotFound) { @connection.post('/stuff.xml') }
    assert_equal 'Stuff found.', @connection.post('/stuff.xml')
  end
end
