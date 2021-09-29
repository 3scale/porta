# frozen_string_literal: true

ThinkingSphinx::Index.define(:metric, with: :real_time) do
  indexes :friendly_name, as: :friendly_name
end
