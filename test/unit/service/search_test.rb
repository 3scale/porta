# frozen_string_literal: true

require 'test_helper'

class Service::SearchTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test 'search without query returns all by default, without sphinx' do
    # TODO: ensure that it is not using sphinx!

    ThinkingSphinx::Test.rt_run do
      services = []

      perform_enqueued_jobs(only: SphinxIndexationWorker) do
        services = FactoryBot.create_list(:simple_service, 2)
      end

      search_results = Service.scope_search({}).select(:id).map(&:id)
      services.each do |service|
        assert_contains search_results, service.id
      end
    end
  end

  test 'search with query by name' do
    ThinkingSphinx::Test.rt_run do
      services = []

      perform_enqueued_jobs(only: SphinxIndexationWorker) do
        services = %w[foo bar].map { |name| FactoryBot.create(:simple_service, name: name) }
      end

      search_results = Service.scope_search(query: 'foo').select(:id).map(&:id)
      expected_service = services.find { |s| s.name.eql?('foo') }
      assert_contains search_results, expected_service.id
    end
  end

  test 'search with query by system_name' do
    ThinkingSphinx::Test.rt_run do
      services = []

      perform_enqueued_jobs(only: SphinxIndexationWorker) do
        services = [
          FactoryBot.create(:simple_service, name: 'one', system_name: 'first'),
          FactoryBot.create(:simple_service, name: 'two', system_name: 'second_api'),
          FactoryBot.create(:simple_service, name: 'three', system_name: 'third_api')
        ]
      end

      search_results = Service.scope_search(query: 'api').select(:id).map(&:id)
      expected_services = services.select { |s| s.system_name.include?('api') }.map(&:id)
      assert_equal search_results.sort, expected_services.sort
    end
  end
end
