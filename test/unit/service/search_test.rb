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

end
