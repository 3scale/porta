# frozen_string_literal: true

namespace :user do
  desc 'Updates the first_admin_id attribute value for all accounts.'
  task update_all_first_admin_id: :environment do
    Account.find_each do |account|
      next if account.first_admin_id.present? || !(user = account.first_admin)

      puts "Failed update of first_admin_id for Account ##{account.id}" unless account.update(first_admin_id: user.id)
    end
    puts 'The accounts\' first_admin_id have been updated.'
  end
end
