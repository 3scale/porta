require 'test_helper'

class Master::Events::ImportsControllerTest < ActionDispatch::IntegrationTest

  def test_route
    MasterDomainConstraint.stubs(matches?: true)
    assert_generates "/master/events/import", action: :create, format: :xml, controller: 'master/events/imports'
    assert_recognizes({action: 'create', format: 'xml', controller: 'master/events/imports'}, {path: master_events_import_path, method: :post})
  end

  def setup
    host! master_account.domain
    ::Events.stubs(shared_secret: 'SECRET')
  end

  test 'is not accessible on other domains' do
    host! 'foo.example.com'
    assert_raise ActionController::RoutingError do
      post master_events_import_path secret: Events.shared_secret
      assert_response :not_found
    end
  end

  test 'check shared secret' do
    post master_events_import_path secret: 'fail'
    assert_response 403

    post master_events_import_path secret: Events.shared_secret
    assert_response :ok
  end

  test 'import asynchronously' do
    Events.expects(:async_fetch_backend_events!)

    post master_events_import_path secret: Events.shared_secret, :host => master_account.domain
  end
end
