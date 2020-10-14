# frozen_string_literal: true

ThinkingSphinx::Index.define(:backend_api, with: :real_time) do
  indexes :name, as: :name
end
