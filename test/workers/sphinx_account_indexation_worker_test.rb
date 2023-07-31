# frozen_string_literal: true

require 'test_helper'

class SphinxAccountIndexationWorkerTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper
  include TestHelpers::Master

  test "master account should not be indexed" do
    ThinkingSphinx::Test.rt_run do
      perform_enqueued_jobs(only: SphinxAccountIndexationWorker) do
        SphinxAccountIndexationWorker.perform_now(Account, master_account.id)
      end
      assert_not_includes Account.search(middleware: ThinkingSphinx::Middlewares::IDS_ONLY, limit: 100), master_account.id
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
      assert_includes Account.search(middleware: ThinkingSphinx::Middlewares::IDS_ONLY, limit: 100), master_account.id

      worker.perform(Account, master_account.id)
      assert_not_includes Account.search(middleware: ThinkingSphinx::Middlewares::IDS_ONLY, limit: 100), master_account.id
      assert_includes Account.search(middleware: ThinkingSphinx::Middlewares::IDS_ONLY, limit: 100), @provider.id
    end
  end
end
