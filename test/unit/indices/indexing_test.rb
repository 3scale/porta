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
    indices.each do |model|
      instance = FactoryBot.create(factory_for model)
      result = indexed_ids(model)
      assert_empty result, "Expected #{model} index #{result} to be empty after create"

      instance.update!(update_for(model))
      result = indexed_ids(model)
      assert_empty result, "Expected #{model} index #{result} to be empty after create"
    end
  end

  test "create, update and destroy updates indices" do
    perform_enqueued_jobs do
      indices.each do |model|
        instance = FactoryBot.create(factory_for model)
        assert_includes indexed_ids(model), instance.id
        assert_empty find_matching(model)

        instance.update!(update_attr_for(model) => update_value_for(model))
        assert_equal [instance], find_matching(model)

        instance.destroy!
        result = indexed_ids(model)
        assert_not_includes indexed_ids(model), instance.id
      end
    end
  end

  private

  def indices
    ThinkingSphinx::Configuration.instance.index_set_class.new.map(&:model).map { |m| m.descendants.presence || m }.flatten
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
    }

    updates[model] || :name
  end

  def update_value_for(model)
    default = "searchstr"

    overrides = {
      ProxyRule => "/#{default}",
    }

    overrides[model] || default
  end

  def find_matching(model)
    model.search(ThinkingSphinx::Query.escape(update_value_for(model))).to_a
  end
end
