ThinkingSphinx::Index.define(:account,
                             with: :active_record,
                             delta: ThinkingSphinx::Deltas::DatetimeDelta,
                             delta_options: { threshold: SPHINX_DELTA_INTERVAL }) do
  indexes :org_name,                           as: :name
  indexes users.username,                      as: :username
  indexes [users.first_name, users.last_name], as: :user_full_name
  indexes users.email,                         as: :email
  indexes bought_cinstances.user_key,          as: :user_key
  indexes bought_cinstances.application_id,    as: :app_id
  indexes bought_cinstances.name,              as: :app_name
  indexes :id,                                 as: :account_id
  indexes users.id,                            as: :user_id

  set_property field_weights: { name: 2 }

  has :provider_account_id
  has :tenant_id

  if System::Database.oracle?
    # FIXME: creating a CRC32 in Oracle needs a custom function ...
    # As we only have few values, I suppose ORA_HASH is enough
    has 'ORA_HASH(accounts.state)', as: :state, type: :integer
    # Need to add the group by otherwise it will complain about ORA-00979 not a Group By function error
    group_by "accounts.state"
  else
    has 'CRC32(accounts.state)', as: :state, type: :integer
  end

  where 'COALESCE(accounts.master, 0) = 0'
end
