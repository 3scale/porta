class Provider::Admin::ApiDocsController < Provider::Admin::BaseController
  activate_menu :account, :integrate, :apidocs

  before_action :disable_client_cache

  layout 'provider'
end
