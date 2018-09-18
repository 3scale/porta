class DeveloperPortal::Admin::Account::PersonalDetailsController < ::DeveloperPortal::BaseController
  inherit_resources

  activate_menu :account, :personal_details

  defaults :singleton => true, :instance_name => 'user', :route_prefix => 'admin_account'
  actions :show, :update
  before_action :ensure_buyer_domain
  before_action :deny_unless_can_update, :only => [:update, :show]

  liquify prefix: 'user'

  def show
    assign_user_drop
  end

  def update
    #TODO: write tests for this
    resource.validate_fields!
    update! do |success, failure|
      success.html do
        if resource.just_changed_password?
          resource.kill_user_sessions(user_session)
        end
        redirect_to(redirect_path)
      end

      failure.html do
        assign_user_drop
        render :action => 'show'
      end
    end
  end

  private

  def assign_user_drop
    drops = { user: Liquid::Drops::User.new(resource)}
    assign_drops(drops)
  end

  def resource
    @user ||= User.find(current_user.id)
  end

  def deny_unless_can_update
    unless can?(:update, current_user)
      render :plain => 'Action disabled', :status => :forbidden
    end
  end

  def redirect_path
    if params[:origin] == "users"
      if current_account.provider?
        provider_admin_account_users_path
      else
        admin_account_users_path
      end
    else
      admin_account_personal_details_path
    end
  end

end
