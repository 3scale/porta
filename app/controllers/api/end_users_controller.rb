class Api::EndUsersController < Api::BaseController
  before_action :authorize_end_users!

  before_action :find_service
  before_action :find_end_user, :only => [:show, :edit, :update, :destroy]
  before_action :find_plans, :only => [:new, :edit, :create, :update]
  before_action :activate_submenu

  sublayout 'api/service'
  activate_menu :serviceadmin, :sidebar => :end_users

  def index
    if params[:id] && find_end_user
      redirect_to admin_service_end_user_path(@service, @end_user)
    end
  end

  def show
    render :index
  end

  def new
    @end_user = EndUser.new @service, params[:end_user]
  end

  def edit
  end

  def create
    @end_user = EndUser.new @service, params[:end_user]

    if @end_user.save
      flash[:success] = "New end user successfully created"
      redirect_to admin_service_end_user_path(@service, @end_user)
    else
      flash[:error] = "New end user could not be created"
      render :new
    end
  end

  def update
    if @end_user.update_attributes params[:end_user]
      flash[:success] = 'Plan changed successfully'
      redirect_to admin_service_end_user_path(@service, @end_user)
    else
      render :edit
    end
  end

  def destroy
    @end_user.destroy

    flash[:success] = "End user deleted successfully"
    redirect_to admin_service_end_users_path(@service)
  end

  private

  def authorize_end_users!
    authorize! :manage, :end_users
  end

  def find_plans
    @plans = @service.end_user_plans
  end

  def find_end_user
    @end_user = EndUser.find @service, params[:id]
  end

end
