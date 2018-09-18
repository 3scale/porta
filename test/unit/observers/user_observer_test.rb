require 'test_helper'

class UserObserverTest < ActiveSupport::TestCase
  disable_transactional_fixtures!

  def buyer_user(attributes)
    buyer_account = Factory(:simple_buyer, provider_account: Factory(:simple_provider))
    Factory.build(:simple_user, attributes.merge(account: buyer_account))
  end

  test 'send email when new user is created' do
    user = buyer_user(signup_type: :new_signup)
    UserMailer.expects(:signup_notification).with(user).returns(mock(deliver_now: true))
    user.save!
  end

  test 'not send signup notification when new user was created with minimal signup' do
    user = buyer_user(signup_type: :minimal)
    UserMailer.expects(:signup_notification).with(user).never
    user.save!
  end

  def provider_user
    Factory.build(:simple_user, signup_type: :new_signup, account: Factory(:simple_provider))
  end

  test 'send provider activation email when new provider user is created' do
    user = provider_user
    ProviderUserMailer.expects(:activation).with(user).returns(mock(deliver_now: true))
    user.save!
  end

  test 'call the activation reminder job when new provider user is created' do
    user = provider_user
    ActivationReminderWorker.expects(:enqueue).with(user).once
    user.save!
  end
end
