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

class ThinkingSphinx::Callbacks
  def self.resume
    return unless ThinkingSphinx::Callbacks.suspended?

    begin
      ThinkingSphinx::Callbacks.resume!
      yield
    ensure
      ThinkingSphinx::Callbacks.suspend!
    end
  end
end

# TODO: handle destroy for models we want incrementally deleted
# ThinkingSphinx::ActiveRecord::Callbacks::DeleteCallbacks.after_destroy(model)
ThinkingSphinx::Callbacks.suspend!
