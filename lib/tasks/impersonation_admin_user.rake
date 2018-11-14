# frozen_string_literal: true

namespace :impersonation_admin_user do
  desc 'updates the username and the email of the impersonation admin user'
  task :update, %i[username domain] => :environment do |_task, args|
    username = ActiveRecord::Base.connection.quote(args[:username])
    domain = ActiveRecord::Base.connection.quote(args[:domain])

    complete_query = if System::Database.oracle?
                       <<~SQL
                         UPDATE users
                          SET username =  #{username},
                              email =  #{username} || '+' ||
                                      (SELECT self_domain FROM accounts WHERE accounts.id = users.account_id) ||
                                      '@' || #{domain}
                          WHERE users.username = '3scaleadmin'
                       SQL
                     else
                       <<~SQL
                         UPDATE users
                         INNER JOIN accounts ON accounts.id = users.account_id
                         SET username = #{username}, email = CONCAT(#{username}, '+', accounts.self_domain, '@', #{domain})
                         WHERE users.username = '3scaleadmin'
                       SQL
                     end
    ActiveRecord::Base.connection.execute(complete_query)
    puts "The impersonation admin users have been updated."
  end
end
