# frozen_string_literal: true

ThinkingSphinx::Index.define(:email_configuration, with: :real_time) do
  indexes email
  indexes user_name
end

module EmailConfigurationIndex
end
