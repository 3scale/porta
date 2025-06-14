class Provider::Admin::SudoController < FrontendController

  helper_method :sudo

  def show; end

  def create
    if sudo.correct_password?(current_password)
      sudo.secure!(period: 1.hour)
      respond_to do |format|
        format.html { redirect_to sudo.return_path, success: t('.success') }
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
    @sudo ||= ::Sudo.new(**sudo_params.to_h.symbolize_keys)
  end

end
