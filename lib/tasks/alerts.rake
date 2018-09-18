desc "Namespace for alerts-related tasks"
namespace :alerts do

  desc "Deletes alerts with the same alert_id & account_id from the database"
  task delete_duplicates: :environment do
    total_count = Alert.count
    puts "Total alerts: #{total_count}"
    unique_ids    = Alert.select("MIN(id) as id").group(:account_id, :alert_id).collect(&:id)
    puts "Unique ids: #{unique_ids.count}"
    puts "Deleting #{total_count - unique_ids.count} alerts ..."
    Alert.where(["alerts.id NOT IN(?)", unique_ids]).delete_all
    puts "Done. Total alerts: #{Alert.count}"
  end

end
