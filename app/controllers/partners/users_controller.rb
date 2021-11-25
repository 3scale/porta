# frozen_string_literal: true

class Partners::UsersController < Partners::BaseController

  before_action :find_account

  def index
    @users = @account.users.page(params.require(:page))
    open_id = params.require(:open_id)
    @users = @users.where(open_id: open_id) if open_id
    render json: @users
  end

  def show
    @user = @account.users.find(params.require(:id))
    render json: @user
  end

  def destroy
    @user = @account.users.find(params.require(:id))
    @user.destroy
    render json: {success: true}
  end

  def create
    @user = @account.users.build
    @user.email = params.require(:email)
    @user.password = SecureRandom.hex
    @user.first_name = params.require(:first_name).presence
    @user.last_name = params.require(:last_name).presence
    @user.open_id = params.require(:open_id).presence
    @user.username = params.require(:username)
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
    @account = @partner.providers.find(params.require(:provider_id))
  end
end
