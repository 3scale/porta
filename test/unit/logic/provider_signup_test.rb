# frozen_string_literal: true

require 'test_helper'

class Logic::ProviderSignupTest < ActiveSupport::TestCase
  class SampleDataTest < ActiveSupport::TestCase
    def setup
      @provider = FactoryBot.create(:provider_account)
    end

    test 'John Doe user is created with weak password when strong passwords enabled' do
      sample_data = Logic::ProviderSignup::SampleData.new(@provider)
      sample_data.create!

      john_doe = @provider.buyer_users.find_by(username: 'john')
      assert john_doe.present?, 'John Doe user should be created'
      assert john_doe.authenticated?('123456'), 'John Doe should have weak password 123456'
    end

    test 'John Doe signup.machine? returns true' do
      sample_data = Logic::ProviderSignup::SampleData.new(@provider)
      sample_data.create!

      john_doe = @provider.buyer_users.find_by(username: 'john')
      assert john_doe.signup.machine?, 'John Doe should be considered a machine signup'
    end

    test 'John Doe signup.sample_data? returns true' do
      sample_data = Logic::ProviderSignup::SampleData.new(@provider)
      sample_data.create!

      john_doe = @provider.buyer_users.find_by(username: 'john')
      assert john_doe.signup.sample_data?, 'John Doe should have sample_data? return true'
    end

    test 'John Doe is active after creation' do
      sample_data = Logic::ProviderSignup::SampleData.new(@provider)
      sample_data.create!

      john_doe = @provider.buyer_users.find_by(username: 'john')
      assert john_doe.active?, 'John Doe should be active after creation'
    end
  end
end
