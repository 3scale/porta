class RemoveOldViolations < ActiveRecord::Migration
  def self.up
    print "\n ==> Dropping all violations older than 30 days \n"
    UsageLimitViolation.delete_all(["created_at < ?", 1.month.ago])

    total_count = UsageLimitViolation.count(:all, :conditions => "period_end IS NULL")
    pages = 10
    per_page = total_count / pages
    
    print "\n Total violations to migrate: #{total_count} (#{per_page} per page, ~ #{pages} pages)\n\n"
    
    page_counter = 0    
    while !(vios = UsageLimitViolation.find(:all, :conditions => "period_end IS NULL", :limit => per_page)).empty? do
      print " ==> Migrating Page: #{page_counter += 1} => "
      time_start = Time.now
      vios.each do |v|
        period = UsageLimit.period_range(v.period_name, v.period_start)
        v.update_attributes(:period_start => period.begin, :period_end => period.end)
      end
      print "#{(Time.now - time_start)} seconds\n"
    end
  end

  def self.down
    # no way back...
  end
end
