# frozen_string_literal: true

ThinkingSphinx::Index.define(:backend_api, with: :real_time) do
  # Fields
  indexes name
  indexes system_name

  # Attributes
end

module BackendApiIndex
end
