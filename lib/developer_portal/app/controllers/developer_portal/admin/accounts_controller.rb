class DeveloperPortal::Admin::AccountsController < DeveloperPortal::BaseController

  liquify prefix: 'account'

  authorize_resource
  activate_menu :account, :overview

  layout 'main_layout'

  before_action :ensure_buyer_domain
  before_action :find_countries,         except: :show
  before_action :deny_unless_can_update, except: :show

  def show
  end

  def edit
  end

  def update
    current_account.validate_fields!

    respond_to do |format|
      if current_account.update_with_flattened_attributes(account_params)
        flash[:notice] = 'The account information was updated.'.freeze
        format.html { redirect_to admin_account_url }
        format.js   { render js: "jQuery.flash.notice('#{flash[:notice]}')" }
      else
        format.html { render action: 'edit' }
        format.js   { render template: 'shared/error' }
      end
    end
  end

  private

  def account_params
    params.require(:account)
  end

  def find_countries
    @countries = Country.all
  end

  def deny_unless_can_update
    # TODO: this should use error rendering stuff... in case is really needed (check authorize_resource)
    unless can?(:update, current_account)
      render :plain => 'Action disabled', :status => :forbidden
    end
  end
end
