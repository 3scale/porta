# frozen_string_literal: true

ThinkingSphinx::Index.define(:service, with: :real_time) do
  # Fields
  indexes name
  indexes system_name

  # Attributes
end

module ServiceIndex
end
