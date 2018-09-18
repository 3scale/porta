class Provider::Admin::ApiDocs::AccountDataController < Provider::Admin::BaseController
  def show
    @data = ::ApiDocs::ProviderUserData.new(current_user)

    respond_to do |format|
      format.json { render :json => @data }
    end
  end
end
