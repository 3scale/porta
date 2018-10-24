class Provider::Admin::User::AccessTokensController < Provider::Admin::User::BaseController
  inherit_resources
  defaults route_prefix: 'provider_admin_user', resource_class: AccessToken
  actions :index, :new, :create, :edit, :update, :destroy

  authorize_resource
  activate_menu :account, :personal, :tokens
  before_action :authorize_access_tokens

  def create
    create! do |success, _failure|
      success.html do
        flash[:token] = @access_token.id
        flash[:notice] = 'Access Token was successfully created.'
        redirect_to(collection_url)
      end
    end
  end

  def index
    index!
    @last_access_key = flash[:token]
  end

  def update
    update! do |success, _failure|
      success.html do
        flash[:notice] = 'Access Token was successfully updated.'
        redirect_to(collection_url)
      end
    end
  end

  private

  def authorize_access_tokens
    authorize! :manage, :access_tokens, current_user
  end

  def begin_of_association_chain
    current_user
  end
end
