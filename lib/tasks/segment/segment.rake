# frozen_string_literal: true

require_dependency 'csv'

namespace :segment do
  desc 'Save as deleted objects the users from the imported segment csv'
  task :save_deleted_users, [:file_name] => [:environment] do |_task, args|
    file_path =  Rails.root.join('config', args[:file_name])
    CSV.foreach(file_path.to_s, headers: true) do |row|
      user_id = Integer(row['User ID'])
      next if User.where(id: user_id).any?
      account_id = row['account_id'].presence
      DeletedObject.create!(object_id: user_id,    object_type: User.name,
                             owner_id: account_id, owner_type: Account.name)
    end
  end
end
