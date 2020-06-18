# frozen_string_literal: true

require 'test_helper'

module Tasks
  class AccountsTest < ActiveSupport::TestCase
    test 'accounts:reset_bought_cinstances_count' do
      account = FactoryBot.create(:simple_buyer)
      FactoryBot.create(:cinstance, user_account: account)
      account.update(bought_cinstances_count: nil)

      execute_rake_task 'accounts.rake', 'accounts:reset_bought_cinstances_count'
      account.reload

      assert_equal account.bought_cinstances_count, account.bought_cinstances.size
    end
  end
end
