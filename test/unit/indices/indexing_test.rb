require 'test_helper'

class IndexingTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  setup do
    ThinkingSphinx::Test.clear
    ThinkingSphinx::Test.init
    ThinkingSphinx::Test.start index: false
  end

  teardown do
    ThinkingSphinx::Test.stop
  end

  test "create and update indices sync callbacks are disabled" do
    indexed_models.each do |model|
      instance = FactoryBot.create(factory_for model)
      result = indexed_ids(model)
      assert_empty result, "Expected #{model} index #{result} to be empty after create"

      instance.update!(update_attr_for(model) => update_value_for(model))
      result = indexed_ids(model)
      assert_empty result, "Expected #{model} index #{result} to be empty after create"
    end
  end

  test "create, update and destroy updates indices" do
    perform_enqueued_jobs do
      indexed_models.each do |model|
        instance = FactoryBot.create(factory_for model)
        assert_includes indexed_ids(model), instance.id
        assert_empty find_matching(model)

        instance.update!(update_attr_for(model) => update_value_for(model))
        assert_equal [instance], find_matching(model)

        instance.destroy!
        assert_not_includes indexed_ids(model), instance.id
      end
    end
  end

  test "there is no sync callback on destroy" do
    indexed_models.each do |model|
      instance = nil
      perform_enqueued_jobs do
        instance = FactoryBot.create(factory_for model)
        assert_includes indexed_ids(model), instance.id
      end

      instance.destroy!
      assert_includes indexed_ids(model), instance.id
    end
  end

  # the idea is to double check #indexed_models lists all models, assuring we cover them all in tests
  test "all models with index methods are indexed" do
    exclusions = [ApplicationRecord, Plan, Cinstance, User]
    index_modules = [Searchable, AccountIndex::ForAccount]
    index_modules << TopicIndex unless System::Database.oracle?

    models = ActiveRecord::Base.descendants.select do |model|
      index_modules.any? { |mod| mod === model.new } unless exclusions.include?(model)
    end

    assert_equal Set.new(models.map(&:name)), Set.new(ThinkingSphinx::Test.indexed_models.map(&:name))
  end

  test 'MySQL uses correct sql index when querying accounts in batches' do
    skip "this test applies to MySQL only" unless System::Database.mysql?

    index = ThinkingSphinx::Test.index_for(Account)

    provider = FactoryBot.create(:simple_provider)
    FactoryBot.create_list(:simple_buyer, 10, provider_account: provider)

    # this query simulates getting accounts in batches with the scope defined for sphinx indexation
    query = "EXPLAIN #{index.scope.where.has{id > provider.id}.order(id: :asc).limit(5).to_sql}"
    res = ActiveRecord::Base.connection.execute(query)
    key = res.fields.index("key")
    # in particular we had an issue where `index_accounts_on_master` was selected instead of PRIMARY
    assert_equal "PRIMARY", res.first[key]
  end

  private

  def indexed_models
    ThinkingSphinx::Test.indexed_models
  end

  def indexed_ids(model)
    model.search(middleware: ThinkingSphinx::Middlewares::IDS_ONLY)
  end

  def factory_for(model)
    overrides = {
      account: :simple_provider,
    }

    factory = model.name.gsub(/:+/, "_").underscore.to_sym
    overrides[factory] || factory
  end

  def update_attr_for(model)
    updates = {
      Metric => :friendly_name,
      ProxyRule => :pattern,
      CMS::Page => :title,
      Topic => :title,
      EmailConfiguration => :email,
    }

    updates[model] || :name
  end

  def update_value_for(model)
    default = "searchstr"

    overrides = {
      ProxyRule => "/#{default}",
      EmailConfiguration => "#{default}@example.redhat.com",
    }

    overrides[model] || default
  end

  def find_matching(model)
    model.search(ThinkingSphinx::Query.escape(update_value_for(model))).to_a
  end
end
