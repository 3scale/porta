# frozen_string_literal: true

ThinkingSphinx::Index.define(:account, with: :real_time) do
  indexes org_name,          as: :name
  indexes id,                as: :account_id
  indexes sphinx_usernames,  as: :username
  indexes sphinx_full_names, as: :user_full_name
  indexes sphinx_emails,     as: :email
  indexes sphinx_user_keys,  as: :user_key
  indexes sphinx_app_ids,    as: :app_id
  indexes sphinx_app_names,  as: :app_name
  indexes sphinx_user_ids,   as: :user_id

  set_property field_weights: { name: 2 }
  #                                                    #     %     '     *  +  ,     .     :     ;     ?     _     `     {     }
  set_property charset_table: "0..9, A..Z->a..z, a..z, U+23, U+25, U+27, U+2A..U+2C, U+2E, U+3A, U+3B, U+3F, U+5F, U+60, U+7B, U+7D"

  has provider_account_id, type: :bigint
  has tenant_id,           type: :bigint
  has state,               type: :string

  scope { Account.searchable }
end
