# frozen_string_literal: true

module ThreeScale
  module Models
    def all_models_with_a_table
      return @all_models_with_a_table if defined?(@all_models_with_a_table)

      Rails.autoloaders.main.eager_load_dir("#{Rails.root}/app/models")
      @all_models_with_a_table = ApplicationRecord.descendants.select(&:arel_table).reject(&:abstract_class?)
    end

    # All actual models excluding abstract and STI base classes
    def leaf_models
      return @leaf_models if defined?(@leaf_models)

      @leaf_models = all_models_with_a_table.select do |model|
        all_models_with_a_table.none? { _1 != model && _1.base_class == model }
      end
    end
  end
end
