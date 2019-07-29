require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class BackendClient::ConnectionTest < ActiveSupport::TestCase
  def setup
    @connection = BackendClient::Connection.new(:host => 'backend.example.org')
  end

  # TODO: test connection errors

  test 'sends get request without params to the backend' do
    stub_request(:get, 'http://backend.example.org/stuff.xml').to_return(body: '<stuff/>')

    @connection.get('/stuff.xml')

    assert_last_request(:get, path: '/stuff.xml')
  end

  test 'sends get request with one param to the backend' do
    stub_request(:get, 'http://backend.example.org/stuff.xml?type=widget').to_return(body: '<stuff/>')

    @connection.get('/stuff.xml', type: 'widget')

    assert_last_request(:get, path: '/stuff.xml?type=widget')
  end

  test 'sends get request with many params to the backend' do
    stub_request(:get, 'http://backend.example.org/stuff.xml?quantity=lot&type=widget').to_return(body: '<stuff/>')

    @connection.get('/stuff.xml', type: 'widget', quantity: 'lot')

    assert_last_request(:get, path: '/stuff.xml?quantity=lot&type=widget')
  end

  test 'escapes params in a request' do
    stub_request(:get, 'http://backend.example.org/stuff.xml?type=atomic+bomb').to_return(body: '<stuff/>')

    @connection.get('/stuff.xml', type: 'widget', type: 'atomic bomb')

    assert_last_request(:get, path: '/stuff.xml?type=atomic%20bomb')
  end

  test 'sends post request to the backend' do
    stub_request(:post, 'http://backend.example.org/stuff.xml').to_return(body: '')
    @connection.post('/stuff.xml', type: 'warpdrive')

    assert_last_request(:post, body: 'type=warpdrive')
  end

  test 'loads configuration from a file' do
    BackendClient.stubs(config: { host: 'backend.test.org:1234'})

    connection = BackendClient::Connection.new
    assert_equal 'backend.test.org:1234', connection.host
  end

  test 'retries the calls' do
    stub_request(:post, 'http://backend.example.org/stuff.xml')
      .to_return(
        { body: 'Post not found',  status: 404 },
        { body: 'Stuff not found', status: 404 },
        { body: 'Stuff found.',     status: 200 },
      )

    BackendClient::Request.any_instance.expects(:failure).twice

    assert_equal 'Stuff found.', @connection.post('/stuff.xml').body
  end

  test 'report error when retried too much' do
    stub_request(:post, 'http://backend.example.org/stuff.xml')
      .to_return(
        { body: 'Post not found',  status: 404 },
        { body: 'Stuff not found', status: 404 },
        { body: 'Stuff not found', status: 404 },
        { body: 'Stuff not found', status: 404 },
        { body: 'Stuff not found', status: 404 },
        { body: 'Stuff found.',     status: 200 },
      )

    BackendClient::Request.any_instance.expects(:failure).times(5)

    System::ErrorReporting.expects(:report_error)
    assert_raise(RestClient::ResourceNotFound) { @connection.post('/stuff.xml') }
    assert_equal 'Stuff found.', @connection.post('/stuff.xml').body
  end
end
