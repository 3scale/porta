# frozen_string_literal: true

namespace :user do
  desc 'Updates the first_admin_id attribute value for all providers.'
  task update_all_first_admin_id: :environment do
    Account.transaction do
      Account.providers.find_each do |account|
        account.update!(first_admin_id: account.first_admin&.id)
      end
    end
  end
end
