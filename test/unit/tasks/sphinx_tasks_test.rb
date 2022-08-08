require 'test_helper'

class SphinxTasksTest < ActiveSupport::TestCase
  include NPlusOneControl::MinitestHelper

  test "enqueuing for indexing performs only one query" do
    ThinkingSphinx::Test.indexed_base_models.each do |model|
      FactoryBot.create(factory_for model)
      # two queries are for count of objects in the model and actual model IDs
      assert_number_of_queries(2) do
        execute_rake_task("sphinx.rake", "sphinx:enqueue", model.to_s)
      end
    end
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
