class Provider::Admin::SudoController < FrontendController

  helper_method :sudo

  def show
  end

  def create
    if sudo.correct_password?(current_password)
      sudo.secure!(period: 1.hour)
      respond_to do |format|
        format.html do
          redirect_to sudo.return_path, notice: 'You are now in super-user mode! Retry the action, please.'
        end
        format.js
      end
    else
      render :show
    end
  end

  protected

  def sudo_params
    params.require(:sudo).permit(:return_path).merge(user_session: user_session)
  end

  def current_password
    params.require(:sudo).fetch(:current_password)
  end

  def sudo
    @_sudo ||= ::Sudo.new(sudo_params.symbolize_keys)
  end

end
