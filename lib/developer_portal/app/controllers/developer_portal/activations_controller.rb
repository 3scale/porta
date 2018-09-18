module DeveloperPortal
  class ActivationsController < DeveloperPortal::BaseController
    liquify

    before_action :do_nothing_if_head, only: [:create]
    skip_before_action :login_required

    def create
      find_user_by_activation_code or return

      if @user.activate
        flash_key = @user.account.approval_required? ? 'approval_required' : 'complete'

        set_flash_message(:notice, "activation_#{flash_key}")
      elsif @user.errors.include?(:email)

        set_flash_message(:error, 'duplicated_user_buyer_side')
      end

      logout_keeping_session!

      # TODO: remove when there are no pending provider users
      # activations without pointing to the buyer side path /activate/xxxxxx
      redirect_to(login_path)
    end

    private

    def set_flash_message(type, key)
      flash[type] = I18n.t("errors.messages.#{key}")
    end

    def find_user_by_activation_code
      @user = site_account.buyer_users.find_by_activation_code(params[:activation_code])
    end
  end
end
