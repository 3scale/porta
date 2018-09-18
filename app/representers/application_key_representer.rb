module ApplicationKeyRepresenter
  include ThreeScale::JSONRepresenter

  wraps_resource :key

  property :value

  property :created_at
  property :updated_at

  link :application do
    admin_api_account_application_url(account, application) if account && application
  end
end
