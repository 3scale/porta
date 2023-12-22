# frozen_string_literal: true

require 'test_helper'

class SphinxAccountIndexationWorkerTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test "master account should not be indexed" do
    ThinkingSphinx::Test.rt_run do
      perform_enqueued_jobs(only: SphinxAccountIndexationWorker) do
        SphinxAccountIndexationWorker.perform_now(Account, master_account.id)
      end
      assert_not_includes indexed_ids(Account), master_account.id
    end
  end

  test "master account should be properly deindexed" do
    ThinkingSphinx::Test.rt_run do
      perform_enqueued_jobs(only: SphinxAccountIndexationWorker) do
        @provider = FactoryBot.create(:simple_provider)
      end
      assert_includes master_account.buyers, @provider

      worker = SphinxAccountIndexationWorker.new
      worker.send :reindex, master_account # enforce indexing master which should not happen in practice
      assert_includes indexed_ids(Account), master_account.id

      worker.perform(Account, master_account.id)
      assert_not_includes indexed_ids(Account), master_account.id
      assert_includes indexed_ids(Account), @provider.id
    end
  end

  test "providers are deleted from index with their buyers" do
    ThinkingSphinx::Test.rt_run do
      perform_enqueued_jobs(only: SphinxAccountIndexationWorker) do
        providers = FactoryBot.create_list(:simple_provider, 2)
        buyers = []
        providers.each { |provider| buyers << FactoryBot.create(:simple_buyer, provider_account: provider) }

        assert_equal (providers + buyers).map(&:id), indexed_ids(Account).to_a

        providers.first.schedule_for_deletion
        providers.first.save!
        indexed = indexed_ids(Account)

        assert Account.exists?(providers.first.id)
        assert Account.exists?(buyers.first.id)
        assert_not_includes indexed, providers.first.id
        assert_not_includes indexed, buyers.first.id
        assert_includes indexed, providers.last.id
        assert_includes indexed, buyers.last.id
      end
    end
  end

  test "buyers are deleted from index without anybody else" do
    ThinkingSphinx::Test.rt_run do
      perform_enqueued_jobs(only: SphinxAccountIndexationWorker) do
        provider = FactoryBot.create(:simple_provider)
        buyers = FactoryBot.create_list(:simple_buyer, 2, provider_account: provider)

        assert_equal Set.new(buyers.map(&:id) << provider.id), Set.new(indexed_ids(Account).to_a)

        buyers.last.destroy!

        indexed = indexed_ids(Account)

        assert_not_includes indexed, buyers.last.id
        assert_includes indexed, provider.id
        assert_includes indexed, buyers.first.id
      end
    end
  end
end
