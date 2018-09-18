require 'test_helper'

class Master::Events::ImportsControllerTest < ActionController::TestCase

  should route(:post, "http://#{master_account.domain}/master/events/import").to :action => :create, :format => :xml

  def host!(domain)
    @request.host = domain
  end

  def setup
    host! master_account.domain
  end

  test 'is not accessible on other domains' do
    host! 'foo.example.com'
    post :create, :secret => Events.shared_secret
    assert_response 403
  end

  test 'check shared secret' do
    post :create, :secret => 'fail'
    assert_response 403

    post :create, :secret => Events.shared_secret
    assert_response :ok
  end

  test 'import asynchronously' do
    Events.expects(:async_fetch_backend_events!)

    post :create, :secret => Events.shared_secret, :host => master_account.domain
  end
end
