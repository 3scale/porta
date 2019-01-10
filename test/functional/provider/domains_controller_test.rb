require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

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

    assert_change :of => lambda { ActionMailer::Base.deliveries.count } do
      post :recover, :email => @provider1.emails.first
    end
    assert_response :success
  end
end
