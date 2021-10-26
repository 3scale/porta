# frozen_string_literal: true

require 'test_helper'

module Tasks
  class SidekiqTest < ActiveSupport::TestCase
    test 'sidekiq:worker' do
      queues = %w[backend_sync billing critical default deletion events low mailers priority web_hooks zync]
                 .flat_map { |queue| ['--queue', queue] }

      Object.any_instance.expects(:exec).with({ 'RAILS_MAX_THREADS' => '1' }, 'sidekiq', '--index', '0', *queues)
      execute_rake_task 'sidekiq.rake', 'sidekiq:worker'
    end
  end
end
