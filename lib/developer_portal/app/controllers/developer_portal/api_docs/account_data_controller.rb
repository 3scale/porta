class DeveloperPortal::ApiDocs::AccountDataController < DeveloperPortal::BaseController
  skip_before_action :login_required

  def show
    @data = ::ApiDocs::BuyerData.new(current_account)

    respond_to do |format|
      format.json { render :json => @data }
    end
  end

end
