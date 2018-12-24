require 'test_helper'

class Provider::Admin::Messages::OutboxControllerTest < ActionController::TestCase

  class RoutingTest < ActionController::TestCase
    def setup
      ProviderDomainConstraint.stubs(matches?: true)
      MasterDomainConstraint.stubs(matches?: true)
    end

    with_options :controller => 'provider/admin/messages/outbox' do |test|
      test.should route(:get, '/p/admin/messages/outbox').to :action => 'index', :controller => 'provider/admin/messages/outbox'
      test.should route(:get, '/p/admin/messages/outbox/new').to :action => 'new', :controller => 'provider/admin/messages/outbox'
      test.should route(:post, '/p/admin/messages/outbox').to :action => 'create', :controller => 'provider/admin/messages/outbox'
      test.should route(:get, '/p/admin/messages/outbox/42').to :action => 'show', :id => '42', :controller => 'provider/admin/messages/outbox'
      test.should route(:delete, '/p/admin/messages/outbox/42').to :action => 'destroy', :id => '42', :controller => 'provider/admin/messages/outbox'
    end
  end

  test 'should render a 404 when given an invalid page parameter' do
    provider = FactoryBot.create :provider_account
    login_as provider.first_admin
    host! provider.admin_domain

    get 'index', :page => 'xoforvfmy'
    assert_response :not_found
  end
end
