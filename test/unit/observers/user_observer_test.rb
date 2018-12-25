require 'test_helper'

class UserObserverTest < ActiveSupport::TestCase
  disable_transactional_fixtures!

  def buyer_user(attributes)
    buyer_account = FactoryBot.create(:simple_buyer, provider_account: FactoryBot.create(:simple_provider))
    FactoryBot.build(:simple_user, attributes.merge(account: buyer_account))
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
    FactoryBot.build(:simple_user, signup_type: :new_signup, account: FactoryBot.create(:simple_provider))
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
