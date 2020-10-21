# frozen_string_literal: true

require 'progress_counter'

namespace :sphinx do
  desc "Enqueue indexation of tables"
  task enqueue: :environment do |_task, args|
    klasses_index = args.to_a
    indices = ThinkingSphinx::RakeInterface.new.rt.send(:indices)
    indices.select! { |ind| klasses_index.include?(ind.model.name) } if klasses_index.any?

    indices.each do |index|
      scope = index.scope
      total = scope.count

      if total.zero?
        puts "Skipping indexation of #{index.model} because no record to index."
        next
      end

      puts "Enqueueing indexation of #{index.model}"
      progress = ProgressCounter.new(total)
      # As we enqueue, we only need the :id
      scope.select(:id).find_in_batches(batch_size: 1000) do |batch|
        batch.each do |record|
          SphinxIndexationWorker.perform_later(record)
        end
        progress.call(increment: batch.size)
      end
      puts
    end
  end
end
