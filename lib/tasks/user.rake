# frozen_string_literal: true

namespace :user do
  desc 'Updates the first_admin_id attribute value for all accounts.'
  task update_all_first_admin_id: :environment do
    impersonation_admin_username = ThreeScale.config.impersonation_admin['username']
    complete_query = <<~SQL
      UPDATE accounts
      SET first_admin_id = ( SELECT id
                             FROM users
                             WHERE accounts.id = users.account_id
                               AND users.role = 'admin'
                               AND users.username <> '#{impersonation_admin_username}'
                             #{System::Database.oracle? ? 'FETCH FIRST 1 ROWS ONLY' : 'LIMIT 1'}
                            )
      WHERE first_admin_id IS NULL
    SQL
    ActiveRecord::Base.connection.execute(complete_query)
    puts 'The accounts\' first_admin_id have been updated.'
  end
end
