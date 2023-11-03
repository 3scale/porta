# frozen_string_literal: true

require 'test_helper'

class SphinxIndexationWorkerTest < ActiveSupport::TestCase

  include ActiveJob::TestHelper

  test 'it does not raises if id does not exist' do
    enable_search_jobs!
    SphinxIndexationWorker.perform_now(ThinkingSphinx::Test.indexed_models.sample, 42)
  end

  test "it re-establishes sphinx connections on certain errors" do
    enable_search_jobs!
    SphinxIndexationWorker.any_instance.expects(:perform).raises(ThinkingSphinx::QueryError, "unknown column: 'sphinx_internal_class_name' - REPLACE INTO account_core (id, `sphinx_internal_class_name`, `name`, `account_id`, `username`, `user_full_name`, `email`, `user_key`, `app_id`, `app_name`, `user_id`, `sphinx_internal_id`, `sphinx_internal_class`, `sphinx_deleted`, `sphinx_updated_at`, `provider_account_id`, `tenant_id`, `state`) VALUES (14978, 'Account', 'org_name-lkdjfggf-serch-yyith8w', '156', 'username-lkdjfggf-serch-xskw25c', ' ', 'username-lkdjfggf-serch-xskw25c@anything.invalid', 'af61253a5933dd9ba30bebb6661d16d1 ede2926ef59ecdc45da4a8960164ffc2', '3173be1c fc507eb9', 'org_name-lkdjfggf-serch-yyith8w's App ui_accou-lkdjfggf-accont-vmt8wba', '180', 156, 'Account', 0, 1697580778, 2, 2, 'approved')")
    ThinkingSphinx::Connection.expects(:clear)

    assert_raises(ThinkingSphinx::QueryError) do
      SphinxIndexationWorker.perform_now(ThinkingSphinx::Test.indexed_models.sample, 42)
    end
  end

  test "it doesn't re-establishes sphinx connections on random errors" do
    enable_search_jobs!
    SphinxIndexationWorker.any_instance.expects(:perform).raises(RuntimeError, "whatever error")
    ThinkingSphinx::Connection.expects(:clear).never

    assert_raises(RuntimeError) do
      SphinxIndexationWorker.perform_now(ThinkingSphinx::Test.indexed_models.sample, 42)
    end
  end
end
