require 'test_helper'

class Apicast::SandboxTest < ActiveSupport::TestCase

  def setup
    @provider = stub(id: 16)
    @config = { shared_secret: 'SECRET',  hosts: [ 'a.net', 'b.net' ] }
  end

  test 'config' do
    assert_raise(ArgumentError) do
      ::Apicast::Sandbox.new(stub(id: 16), shared_secret: 'stuff')
    end
  end

  test 'deploy exceptions' do
    sandbox = ::Apicast::Sandbox.new(@provider, shared_secret: 'foo', hosts: ['a.net'])
    sandbox.raise_exceptions = true

    stub_request(:get, 'http://a.net/deploy/foo?provider_id=16').to_timeout

    assert_raise HTTPClient::TimeoutError do sandbox.deploy end

    sandbox.raise_exceptions = false
    refute sandbox.deploy, 'should have failed'
  end

  test 'deploy failure' do
    sandbox = ::Apicast::Sandbox.new(@provider, @config)
    sandbox.raise_exceptions = true

    stub_request(:get, 'http://a.net/deploy/SECRET?provider_id=16').to_return(status: 200)
    stub_request(:get, 'http://b.net/deploy/SECRET?provider_id=16').to_return(status: 500)

    refute sandbox.deploy, 'deploy should have failed'
  end

  test 'deploy success' do
    stub_request(:get, 'http://a.net/deploy/SECRET?provider_id=16').to_return(status: 200)
    stub_request(:get, 'http://b.net/deploy/SECRET?provider_id=16').to_return(status: 200)

    sandbox = ::Apicast::Sandbox.new(@provider, @config)
    sandbox.raise_exceptions = true

    assert sandbox.deploy, 'deploy failed'
  end

end
