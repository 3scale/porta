# frozen_string_literal: true

module ThreeScale
  module Models
    def all_models_with_a_table
      return @all_models_with_a_table if defined?(@all_models_with_a_table)

      Rails.autoloaders.main.eager_load_dir(Rails.root.join("app/models"))
      @all_models_with_a_table = ApplicationRecord.descendants.select(&:arel_table).reject(&:abstract_class?)
    end

    def three_scale_db_models
      @three_scale_db_models ||= all_models_with_a_table.reject { _1.name.match(/^.+Test::.+$/) }
    end

    # All actual models excluding abstract and STI base classes
    def leaf_models
      return @leaf_models if defined?(@leaf_models)

      @leaf_models = three_scale_db_models.select do |model|
        three_scale_db_models.none? { _1 != model && _1.base_class == model }
      end
    end

    # All actual models base models excluding abstract (no sti models)
    def base_models
      return @base_models if defined?(@base_models)

      @base_models = three_scale_db_models.select do |model|
        base_class = model.base_class
        # either current model is the base_class
        base_class == model ||
          # or we can't find a base class amongst the discovered models /which would be very weird/
          three_scale_db_models.none? { |potential_parent| potential_parent == base_class }
      end
    end

    def all_objects
      base_models.inject(Set.new) do |acc, model|
        acc.merge model.all
      end
    end
  end
end
