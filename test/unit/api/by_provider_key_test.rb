require 'test_helper'

class ApiAuthentication::ByProviderKeyTest < ActiveSupport::TestCase

  class Params
    include ApiAuthentication::ByProviderKey

    public :current_account

    attr_accessor :params, :request

    def initialize(params)
      @params = params
    end

    def current_user; end
  end

  test 'scopes search by domain' do
    p1 = Factory(:provider_account)
    p2 = Factory(:provider_account)

    object = Params.new(:provider_key => p2.api_key)
    object.request = mock(:host => p2.self_domain)

    assert object.current_account

    object = Params.new(:provider_key => p1.api_key)
    object.request = mock(:host => p2.self_domain)
    assert ! object.current_account
  end
end
