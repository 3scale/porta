class DeveloperPortal::Admin::Account::UsersController < ::DeveloperPortal::BaseController
  before_action :ensure_buyer_domain

  inherit_resources
  defaults :route_prefix => 'admin_account'
  actions :index, :edit, :update, :destroy

  authorize_resource

  activate_menu :account, :users

  liquify prefix: 'accounts/users'

  def index
    users = Liquid::Drops::User.wrap(collection)
    pagination = Liquid::Drops::Pagination.new(collection, self)
    assign_drops users: users, pagination: pagination
  end

  def edit
    assign_liquid_drops
  end

  def update
    @user.validate_fields!

    update! do |success, failure|
      success.html do
        flash[:notice] = 'User was successfully updated.'
        redirect_to(collection_url)
      end

      failure.html do
        assign_liquid_drops
        render action: 'edit'
      end
    end
  end

  private

  def assign_liquid_drops
    assign_drops user: resource
  end

  def begin_of_association_chain
    current_account
  end

  def collection
    @users ||= end_of_association_chain.paginate(:page => params[:page])
  end

  def update_resource(user, attributes)
    attributes.each do |attrs|
      user.attributes = attrs
      user.role = attrs[:role] if can? :update_role, user
    end
    user.save
  end
end
