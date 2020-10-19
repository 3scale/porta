# frozen_string_literal: true

require 'test_helper'

class BackendApi::SearchTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test 'search without query returns all by default, without sphinx' do
    # TODO: ensure that it is not using sphinx!

    ThinkingSphinx::Test.rt_run do
      backend_apis = []

      perform_enqueued_jobs(only: SphinxIndexationWorker) do
        backend_apis = FactoryBot.create_list(:backend_api, 2)
      end

      search_results = BackendApi.scope_search({}).select(:id).map(&:id)
      backend_apis.each do |backend_api|
        assert_contains search_results, backend_api.id
      end
    end
  end

  test 'search with query by name' do
    ThinkingSphinx::Test.rt_run do
      backend_apis = []

      perform_enqueued_jobs(only: SphinxIndexationWorker) do
        backend_apis = %w[foo bar].map { |name| FactoryBot.create(:backend_api, name: name) }
      end

      search_results = BackendApi.scope_search(query: 'foo').select(:id).map(&:id)
      expected_backend_api = backend_apis.find { |s| s.name.eql?('foo') }
      assert_contains search_results, expected_backend_api.id
    end
  end

end
