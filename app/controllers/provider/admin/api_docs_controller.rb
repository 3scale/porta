class Provider::Admin::ApiDocsController < Provider::Admin::BaseController
  activate_menu :account, :integrate, :apidocs

  layout 'provider'
end
