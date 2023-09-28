require 'test_helper'

class SearchdTasksTest < ActiveSupport::TestCase
  include NPlusOneControl::MinitestHelper

  test "enqueuing for indexing performs only one query" do
    ThinkingSphinx::Test.indexed_base_models.each do |model|
      FactoryBot.create(factory_for model)
      # two queries are for count of objects in the model and actual model IDs
      assert_number_of_queries(2) do
        execute_rake_task("searchd.rake", "searchd:enqueue", model.to_s)
      end
    end
  end

  test "simple optimize task test" do
    out, err = capture_io do
      ThinkingSphinx::Test.rt_run do
        execute_rake_task("searchd.rake", "searchd:optimize")
      end
    end

    assert_match /_core enqueued for optimization/, out + err
  end

  private

  def factory_for(model)
    overrides = {
      account: :simple_provider,
      plan: :application_plan,
    }

    factory = model.name.gsub(/:+/, "_").underscore.to_sym
    overrides[factory] || factory
  end
end
