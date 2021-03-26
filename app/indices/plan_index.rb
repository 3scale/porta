# frozen_string_literal: true

ThinkingSphinx::Index.define(:plan, with: :real_time) do
  indexes :name, as: :name
end
