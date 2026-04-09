# frozen_string_literal: true

require 'test_helper'

class Logic::CMSTest < ActiveSupport::TestCase
  setup do
    @provider = FactoryBot.create(:provider_account)
  end

  class SampleDeveloperTest < Logic::CMSTest
    setup do
      Logic::ProviderSignup::SampleData.new(@provider).create!
    end

    test 'sample_developer_john_doe returns John Doe user from the Developer buyer' do
      john = @provider.sample_developer_john_doe
      assert john.present?
      assert_equal 'john', john.username
      assert_equal 'John', john.first_name
      assert_equal 'Doe', john.last_name
      assert_equal :admin, john.role
      assert_equal 'Developer', john.account.org_name
    end

    test 'john_doe_still_here? returns true when password is unchanged' do
      assert @provider.john_doe_still_here?
    end

    test 'john_doe_still_here? returns false when password has been changed' do
      john = @provider.sample_developer_john_doe
      new_password = 'aNewStrongPassword1'
      john.update!(password: new_password, password_confirmation: new_password)

      assert_not @provider.john_doe_still_here?
    end
  end

  class SampleDeveloperMissingTest < Logic::CMSTest
    test 'john_doe_still_here? returns false when no John Doe exists' do
      assert_not @provider.john_doe_still_here?
    end

    test 'sample_developer_john_doe returns nil when no matching user exists' do
      assert_nil @provider.sample_developer_john_doe
    end

    test 'john_doe_still_here? returns false when a user called John Doe exists but not in the Developer buyer' do
      other_buyer = FactoryBot.create(:buyer_account, provider_account: @provider, org_name: 'Some Company')
      FactoryBot.create(:user, account: other_buyer, username: 'john', first_name: 'John', last_name: 'Doe', role: :admin)

      assert_not @provider.john_doe_still_here?
    end

    test 'sample_developer_john_doe returns nil when a user called John Doe exists but not in the Developer buyer' do
      other_buyer = FactoryBot.create(:buyer_account, provider_account: @provider, org_name: 'Some Company')
      FactoryBot.create(:user, account: other_buyer, username: 'john', first_name: 'John', last_name: 'Doe', role: :admin)

      assert_nil @provider.sample_developer_john_doe
    end

    test 'john_doe_still_here? returns false when the Developer buyer exists but has no John Doe' do
      FactoryBot.create(:buyer_account, provider_account: @provider, org_name: 'Developer')

      assert_not @provider.john_doe_still_here?
    end

    test 'sample_developer_john_doe returns nil when the Developer buyer exists but has no John Doe' do
      FactoryBot.create(:buyer_account, provider_account: @provider, org_name: 'Developer')

      assert_nil @provider.sample_developer_john_doe
    end
  end
end
