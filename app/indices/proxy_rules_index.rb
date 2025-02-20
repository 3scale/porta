# frozen_string_literal: true

ThinkingSphinx::Index.define(:proxy_rule, with: :real_time) do
  # Fields
  indexes pattern

  # Attributes
  has owner_id,   type: :bigint
  has owner_type, type: :string

  #                                                    -     .     _     ~
  set_property charset_table: "0..9, A..Z->a..z, a..z, U+2D, U+2E, U+5F, U+7E"
end
