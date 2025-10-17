# frozen_string_literal: true

class Sites::EmailsController < Sites::BaseController
  provider_required

  prepend_before_action :deny_on_premises_for_master

  helper_method :presenter

  activate_menu :audience, :messages, :email

  def edit; end

  def update
    account_params = params.require(:account).permit(%i[support_email finance_support_email])

    if current_account.update(account_params)
      redirect_to({ action: :edit }, success: t('.success'))
    else
      flash.now[:error] = t('.error')
      render :edit
    end
  end

  private

  def presenter
    @presenter ||= Sites::EmailsEditPresenter.new(user: current_user)
  end
end
