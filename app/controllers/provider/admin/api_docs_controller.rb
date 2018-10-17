class Provider::Admin::ApiDocsController < Provider::Admin::BaseController
  activate_menu :account, :integrate, :apidocs

  layout 'provider'

  def show
    render current_account.provider_can_use?(:new_provider_documentation) ? 'show-v2' : action_name
  end

end
