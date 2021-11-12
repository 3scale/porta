require 'test_helper'

class Provider::DomainsControllerTest < ActionController::TestCase
  def setup
    @provider1 = FactoryBot.create :provider_account
    @provider2 = FactoryBot.create :provider_account
    u = @provider2.users.first
    u.email = @provider1.emails.first
    u.save!
  end

  test 'email list of domains' do
    @request.host = Account.master.domain

    assert_change :of => -> { ActionMailer::Base.deliveries.count } do
      post :recover, params: { email: @provider1.emails.first }
    end
    assert_response :success
  end
end
