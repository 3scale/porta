# frozen_string_literal: true

require 'test_helper'

class Logic::SampleDeveloperPasswordTest < ActiveSupport::TestCase
  setup do
    @provider = FactoryBot.build_stubbed(:provider_account, id: 42, created_at: Time.zone.parse('2024-01-01 00:00:00'))
  end

  test 'generates a password of the required length' do
    assert_equal Authentication::ByPassword::STRONG_PASSWORD_MIN_SIZE,
                 Logic::SampleDeveloperPassword.for(@provider).length
  end

  test 'generates the expected password' do
    # Fixed example values, we need to control them in order to get the result we expect
    # The goal of the test is to ensure the password generation algorithm doesn't change
    fixed_subkey = ["50fba4e47d27efaced39c6532d64884e94bc7d03dc03c192f37e0877a1f73efc"].pack("H*")
    Logic::SampleDeveloperPassword.stub(:subkey, fixed_subkey) do
      provider = stub("provider", id: 42, created_at: Time.utc(2026, 4, 1))
      assert_equal "xYDM-3YMTOyAcMO", Logic::SampleDeveloperPassword.for(provider)
    end
  end

  test 'is deterministic for the same provider' do
    assert_equal Logic::SampleDeveloperPassword.for(@provider),
                 Logic::SampleDeveloperPassword.for(@provider)
  end

  test 'differs for providers with different id' do
    other = FactoryBot.build_stubbed(:provider_account, id: 99, created_at: @provider.created_at)
    assert_not_equal Logic::SampleDeveloperPassword.for(@provider),
                     Logic::SampleDeveloperPassword.for(other)
  end

  test 'differs for providers with the same id but different created_at' do
    other = FactoryBot.build_stubbed(:provider_account, id: @provider.id, created_at: @provider.created_at + 1.second)
    assert_not_equal Logic::SampleDeveloperPassword.for(@provider),
                     Logic::SampleDeveloperPassword.for(other)
  end

  test 'produced password can authenticate via BCrypt' do
    password = Logic::SampleDeveloperPassword.for(@provider)
    digest   = BCrypt::Password.create(password)
    assert BCrypt::Password.new(digest) == password
  end
end
