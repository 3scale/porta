require 'test_helper'

class Provider::InviteeSignupsControllerTest < ActionController::TestCase

  class RoutingTest < ActionController::TestCase
    def setup
      ProviderDomainConstraint.stubs(matches?: true)
      MasterDomainConstraint.stubs(matches?: true)
    end

    should route(:get, '/p/signup/token').to(action: 'show', invitation_token: 'token')
    should route(:post, '/p/signup/token').to(action: 'create', invitation_token: 'token')
  end

end
