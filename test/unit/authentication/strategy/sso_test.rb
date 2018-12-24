require 'test_helper'

class Authentication::Strategy::SsoTest < ActiveSupport::TestCase

  def setup
    @provider = FactoryBot.create(:provider_account)
    @account  = FactoryBot.create(:buyer_account, provider_account: @provider)
    @strategy = Authentication::Strategy.build(@provider)
  end

  def test_authenticate_wrong_credentials
    stub_extract! [-1, 'supetramp']

    refute @strategy.authenticate({ token: '123', expires_at: expires_at })
  end

  def test_authenticate_user_id
    user = FactoryBot.create(:active_user, account: @account)

    stub_extract! [user.id, 'supetramp']

    assert @strategy.authenticate({ token: '123', expires_at: expires_at })
  end

  def test_authenticate_username
    user = FactoryBot.create(:active_user, account: @account)

    stub_extract! [nil, user.username]

    assert @strategy.authenticate({ token: '123', expires_at: expires_at })
  end

  private

  def stub_extract!(result)
    ThreeScale::SSO::Encryptor.any_instance.stubs(:extract!).returns(result)
  end

  def expires_at
    (DateTime.now + 1.day).to_s
  end
end
