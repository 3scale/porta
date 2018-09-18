class Sites::EmailsController < Sites::BaseController

  provider_required

  activate_menu :settings, :site
  sublayout 'emails'

  before_action :find_account
  before_action :find_services
  prepend_before_action :deny_on_premises_for_master

  def edit
  end

  def update
    unless @account.update_attributes(params[:account])
      not_saved = true
    end

    @services.each do |service|
      unless service.update_attributes :support_email => params["service_#{service.id}_support_email"]
        not_saved = true
      end
    end

    flash[:notice] = if not_saved
                       'There were errors saving some of your emails. Please review the marked fields.'
                     else
                       'Your support emails have been updated.'
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
