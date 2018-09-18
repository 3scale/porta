module UserRepresenter
  include ThreeScale::JSONRepresenter
  include FieldsRepresenter
  include ExtraFieldsRepresenter

  wraps_resource

  property :id
  property :state
  property :cas_identifier, if: ->(*) { signup.cas? }
  property :open_id, if: ->(*) { signup.open_id? }
  property :role

  property :created_at
  property :updated_at

  # TODO: extra fields

  link :account do
    unless account.provider?
      admin_api_account_url(account)
    end
  end

  link :self do
    if account.provider?
      admin_api_users_url(id) if id
    else
      admin_api_account_user_url(account, id) if id
    end
  end

end
