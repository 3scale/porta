# frozen_string_literal: true

namespace :end_user_switch do
  desc 'Disable end user switch for all accounts'
  task disable_all: :environment do
    Settings.find_in_batches(batch_size: 5000) do |group|
      ids = group.collect(&:id)
      puts "Updating #{ids.length} settings."
      Settings.where(id: ids).update_all(end_users_switch: 'denied')
      puts "Done: Updating #{ids.length} settings."
      sleep(2)
    end
  end
end
