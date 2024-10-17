# frozen_string_literal: true

require 'progress_counter'

# Run like this multiple times as new jobs can be scheduled while running
# bundle exec rails runner script/stop_delete_jobs.rb Hierarchy-Service-2555417726785

# e.g. "Hierarchy-Service-2555417734629"
ROOT_OBJECT_TO_DELETE = ARGV.shift
QUEUES = %w[default deletion].freeze

def each_with_progress_counter(enumerable, count)
  progress = ProgressCounter.new(count)
  enumerable.each do |element|
    yield element
    progress.call
  end
end

def job_matches_conditions(job)
  return false unless job.item && job.item["args"].is_a?(Array)

  first_arg = job.item["args"].first
  !first_arg.is_a?(Numeric) &&
    %w[DeleteObjectHierarchyWorker DeleteAccountHierarchyWorker DeletePlainObjectWorker].include?(first_arg["job_class"]) &&
    first_arg["arguments"].is_a?(Array) &&
    first_arg["arguments"][1] && first_arg["arguments"][1].include?(ROOT_OBJECT_TO_DELETE)
end

def delete_from_queue(queue_name)
  queue = Sidekiq::Queue.new(queue_name)
  puts "Deleting from queue '#{queue_name}'..."
  count = 0

  each_with_progress_counter(queue, queue.size) do |job|
    next unless job_matches_conditions(job)

    # pp job.item["args"]
    job.delete
    count += 1
    # puts '------------------------------------------------------------'
  end
  puts "#{count} jobs deleted from queue '#{queue_name}'!"
end

def delete_from_scheduled
  ss = Sidekiq::ScheduledSet.new
  puts "Deleting from scheduled set..."
  count = 0
  each_with_progress_counter(ss, ss.size) do |job|
    next unless job_matches_conditions(job)

    # pp job.item["args"]
    job.delete
    count += 1
    # puts '------------------------------------------------------------'
  end
  puts "#{count} jobs deleted from scheduled set!"
end

delete_from_scheduled

QUEUES.each { delete_from_queue(_1) }
