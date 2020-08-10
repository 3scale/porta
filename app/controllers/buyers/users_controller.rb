class Buyers::UsersController < Buyers::BaseController
  activate_menu :audience, :accounts, :listing

  inherit_resources
  actions :index, :show, :edit
  defaults :route_prefix => 'admin_buyers' #FIXME: inherited_resource makes us repeat this
  belongs_to :account, :collection_name => :buyer_accounts

  def update
    # TODO: I think this controller is used only on provider side
    resource.validate_fields! if current_account.buyer?
    resource.attributes = params[:user] # TODO: we should filter the params

    if update_resource(resource, resource_params)
      flash[:notice] = 'User was successfully updated.'
      redirect_to action: :show
    else
      render :edit
    end
  end

  def destroy
    if resource.destroy
      flash[:notice] = 'User was successfully deleted.'
      redirect_to action: :index
    else
      flash[:error] = 'User could not be deleted.'
      redirect_back_or_show_detail
    end
  end

  def suspend
    resource.suspend!
    flash[:notice] = 'User was suspended'

    redirect_back_or_show_detail
  end

  def unsuspend
    resource.unsuspend!
    flash[:notice] = 'User was unsuspended'

    redirect_back_or_show_detail
  end

  def activate
    if resource.activate
      resource.account.create_onboarding

      flash[:notice] = 'User was activated'
    else
      error_message = if resource.errors.include?(:email)
        I18n.t('errors.messages.duplicated_user_provider_side')
                      else
        resource.errors.full_messages.join(',')
      end

      flash[:error] = 'Failed to activate user: ' << error_message
    end

    redirect_back_or_show_detail
  end

  protected

  def redirect_back_or_show_detail
    redirect_to(:back)
  rescue ActionController::RedirectBackError
    redirect_to admin_buyers_account_user_path(account_id: resource.account_id, id: resource.id)
  end

  def begin_of_association_chain
    current_account
  end

  def resource
    @user ||= current_account.buyer_users.find(params[:id]).decorate
  end

  def collection
    @users ||= end_of_association_chain.order(:id).paginate(page: params[:page]).decorate
  end

  def update_resource(user, attributes)
    # FIXME: for some reason this is an array now
    attributes = attributes.first

    user.attributes = attributes
    user.role = attributes[:role] if can? :update_role, user
    user.save
  end
end
