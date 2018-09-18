module AccountsRepresenter
  include ThreeScale::JSONRepresenter

  wraps_collection :accounts
  items extend: AccountRepresenter

  link :self do
    admin_api_accounts_url
  end
end
