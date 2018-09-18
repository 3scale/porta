# frozen_string_literal: true

require 'test_helper'

class Tasks::SidekiqTest < ActiveSupport::TestCase
  include TestHelpers::FakeWeb

  test 'sidekiq:worker' do
    Rails.application.eager_load!
    active_job_classes = ActiveJob::Base.descendants
    sidekiq_classes = ObjectSpace.each_object(Class).select { |c| c.included_modules.include? Sidekiq::Worker }

    active_job_queues = active_job_classes.map { |c| c.try(:queue_name)&.to_s }.compact.to_set
    sidekiq_queues = sidekiq_classes.map { |c| (c.try(:get_sidekiq_options) || {})['queue']&.to_s }.compact.to_set
    all_queues = active_job_queues.merge(sidekiq_queues)

    sorted_and_formatted_queues = %w[--index 0] + all_queues.to_a.sort.flat_map { |queue| ['--queue', queue] }

    Object.any_instance.expects(:exec).with({'RAILS_MAX_THREADS'=>'1'}, 'sidekiq', *sorted_and_formatted_queues.flatten)
    execute_rake_task 'sidekiq.rake', 'sidekiq:worker'
  end
end
