# frozen_string_literal: true

ThinkingSphinx::Index.define(:email_configuration, with: :real_time) do
  indexes :user_name

  # has :account_id, type: :bigint # TODO: useful?
end
