# Patches ThinkingSphinx so `sphinx_internal_class_name` field is enabled
# for rt indices of Single-table inheritance models
# upstream https://github.com/pat/thinking-sphinx/pull/1249
ThinkingSphinx::Configuration::MinimumFields.prepend(Module.new do
  private

  def indices_of_type(type)
    super.reject(&method(:inheritance_columns?))
  end
end)
