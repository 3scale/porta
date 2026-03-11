class Partners::UsersController < Partners::BaseController

  before_action :find_account

  def index
    @users = @account.users.page(params[:page])
    @users = @users.where(open_id: params[:open_id]) if params[:open_id]
    render json: @users
  end

  def show
    @user = @account.users.find(params[:id])
    render json: @user
  end

  def destroy
    @user = @account.users.find(params[:id])
    @user.destroy
    render json: {success: true}
  end

  def create
    @user = @account.users.build(user_params)
    @user.password = SecureRandom.hex
    @user.signup_type = :partner
    @user.role = :admin
    @user.activate!
    if @user.save
      render json: {id: @user.id, success: true}
    else
      render json: {errors: @user.errors, success: false}
    end
  end

  private

  def find_account
    @account = @partner.providers.find(params[:provider_id])
  end

  def user_params
    allowed_attrs = %i(email first_name last_name open_id username)
    params.permit(*allowed_attrs)
  end
end
