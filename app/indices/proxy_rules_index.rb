# frozen_string_literal: true

ThinkingSphinx::Index.define(:proxy_rule, with: :real_time) do
  indexes :pattern

  has owner_id, as: :owner_id, type: :integer
  has owner_type, as: :owner_type, type: :string

  set_property min_infix_len: 1
end
