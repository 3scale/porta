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
      scope.select(:id).except(:includes).find_in_batches(batch_size: 1000) do |batch|
        batch.each do |record|
          SphinxLowPrioIndexationWorker.perform_later(record.class, record.id)
        end
        progress.call(increment: batch.size)
      end
      # TODO: when we implement clean-up, add the logic here or perhaps just run
      #       the whole ThinkingSphinx::RealTime::Populator in a single worker
      #       see https://github.com/pat/thinking-sphinx/pull/1192
      #       see https://github.com/pat/thinking-sphinx/issues/1215
      puts
    end
  end
end
