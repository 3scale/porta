# frozen_string_literal: true

ThinkingSphinx::Index.define(:proxy_rule, with: :real_time) do
  # Fields
  indexes pattern

  # Attributes
  has owner_id,   type: :bigint
  has owner_type, type: :string

  set_property min_infix_len: 1
  #                                                    !     '     ()*+,-./    _
  set_property charset_table: "0..9, A..Z->a..z, a..z, U+21, U+27, U+28..U+2F, U+5F"
end

module ProxyRulesIndex
end
