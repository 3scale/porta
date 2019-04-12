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

  task :obfuscate_buyer_private_data_and_repair_tenant_id, [:user_ids] => [:environment] do |_task, args|
    User.where(id: args[:user_ids]).find_each do |user|
      tenant_id = user.account.provider_account_id
      user.update!({username: "someone#{user.id}", email: "someone#{user.id}@example.com", tenant_id: tenant_id}, without_protection: true)
      user.account.update!({tenant_id: tenant_id}, without_protection: true)
    end
  end
end
