class Sites::EmailsController < Sites::BaseController

  provider_required

  activate_menu :audience, :messages, :email

  before_action :find_account
  before_action :find_services
  prepend_before_action :deny_on_premises_for_master

  def edit
  end

  def update
    unless @account.update(params[:account])
      not_saved = true
    end

    @services.each do |service|
      unless service.update :support_email => params["service_#{service.id}_support_email"]
        not_saved = true
      end
    end

    if not_saved
      flash.now[:warning] = t('.warning')
    else
      flash.now[:success] = t('.success')
    end

    render 'edit'
  end

  private

  def find_account
    @account = current_account
  end

  def find_services
    @services = @account.accessible_services
  end

end
