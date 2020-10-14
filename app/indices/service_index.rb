# frozen_string_literal: true

ThinkingSphinx::Index.define(:service, with: :real_time) do
  indexes :name, as: :name
end
