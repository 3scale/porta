# frozen_string_literal: true

class ProgressBar
  def initialize(total, description)
    @total   = total
    @counter = 1
  end

  def increment
    complete = sprintf("%#.2f%", ((@counter.to_f / @total.to_f) * 100))
    print "\r\e[0K#{@counter}/#{@total} (#{complete})"
    @counter += 1
  end
end

namespace :jobs do
  namespace :cancel do
    desc 'Cancel all scheduled deletion of objects in the database. WARNING, please purge the jobs before'
    task :delete_object_worker => :environment do
      set = Sidekiq::BatchSet.new
      progress = ProgressBar.new(set.size, 'Cancel scheduled deletion jobs')
      set.each do |status|

        batch = Sidekiq::Batch.new(status.bid)
        # The check is from:
        # https://github.com/3scale/porta/blob/15adc8fc0bcee2c8fefe114218ea50b368de4a98/app/workers/delete_object_hierarchy_worker.rb#L61
        # and
        # https://github.com/3scale/porta/blob/15adc8fc0bcee2c8fefe114218ea50b368de4a98/app/workers/delete_account_hierarchy_worker.rb#L17-L21
        if batch.description =~ /^(Deleting provider|Deleting buyer|Deleting \w+ \[\d+\])/
          # Invalidate batch, so we can perform a logical cancel of jobs in the Worker as per https://github.com/mperham/sidekiq/wiki/Batches#canceling-a-batch
          batch.invalidate_all
          # Just deleting the batch from Redis, they will need to be deleted before running this script
          status.delete
        end
        progress.increment
      end
    end
  end
end
