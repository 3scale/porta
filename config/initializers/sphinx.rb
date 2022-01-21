SPHINX_DELTA_INTERVAL = 90.minutes

# Patches ThinkingSphinx so `sphinx_internal_class_name` field is avoided
# for no inheritance indices despite other indices with inheritance defined
ThinkingSphinx::Configuration::MinimumFields.prepend(Module.new do
  private

  def indices
    super.reject do |index|
      model = index.model
      model.table_exists? && model.column_names.include?(model.inheritance_column)
    end
  end

  def no_inheritance_columns?
    true
  end
end)

# TODO: in ts v5.3 it probably shouldn't hurt to allow callbacks so we have
#       destroy for models automatically, see
# ThinkingSphinx::ActiveRecord::Callbacks::DeleteCallbacks.after_destroy(model)
ThinkingSphinx::Callbacks.suspend!
