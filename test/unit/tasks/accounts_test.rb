# frozen_string_literal: true

require 'test_helper'

module Tasks
  class AccountsTest < ActiveSupport::TestCase
    test 'accounts:reset_bought_cinstances_count' do
      account = FactoryBot.create(:simple_buyer)
      FactoryBot.create(:cinstance, user_account: account)

      sql_update_nil = <<-SQL
        UPDATE  accounts
        SET     bought_cinstances_count = NULL
        WHERE   accounts.id = #{account.id}
      SQL
      ActiveRecord::Base.connection.execute(sql_update_nil)

      assert_nil account.reload.bought_cinstances_count

      execute_rake_task 'accounts.rake', 'accounts:reset_bought_cinstances_count'

      account.reload
      assert_equal account.bought_cinstances_count, account.bought_cinstances.count
    end
  end
end
