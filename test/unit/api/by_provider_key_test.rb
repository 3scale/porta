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
    p1 = FactoryBot.create(:provider_account)
    p2 = FactoryBot.create(:provider_account)

    request = ActionDispatch::TestRequest.create
    request.host = p2.external_admin_domain

    object = Params.new(:provider_key => p2.api_key)
    object.request = request

    assert object.current_account

    object = Params.new(:provider_key => p1.api_key)
    object.request = request
    assert ! object.current_account
  end
end
