require 'test_helper'

class Authentication::Strategy::TokenTest < ActiveSupport::TestCase

  def setup
    @provider = FactoryBot.create(:provider_account)
    @strategy = Authentication::Strategy.build_strategy(:token).new(@provider, true)
  end

  def test_authenticate_wrong_credentials
    stub_extract! [-1, 'supetramp']

    refute @strategy.authenticate({ token: '123', expires_at: expires_at })
  end

  def test_authenticate_user_id
    user = FactoryBot.create(:active_user, account: @provider)

    stub_extract! [user.id, 'supetramp']

    assert @strategy.authenticate({ token: '123', expires_at: expires_at })
  end

  def test_authenticate_username
    user = FactoryBot.create(:active_user, account: @provider)

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
