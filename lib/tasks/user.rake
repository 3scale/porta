# frozen_string_literal: true

namespace :user do
  desc 'Updates the first_admin_id attribute value for all accounts.'
  task update_all_first_admin_id: :environment do
    Account.where(first_admin_id: nil).find_each do |account|
      next unless (user = account.first_admin)

      puts "Failed update of first_admin_id for Account ##{account.id}" unless account.update_column(:first_admin_id, user.id) # rubocop:disable Rails/SkipsModelValidations
    end
    puts 'The accounts\' first_admin_id have been updated.'
  end
end
