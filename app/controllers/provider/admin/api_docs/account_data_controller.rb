# frozen_string_literal: true

class Provider::Admin::ApiDocs::AccountDataController < Provider::Admin::BaseController
  before_action :disable_client_cache

  def show
    @data = ::ApiDocs::ProviderUserData.new(current_user)

    respond_to do |format|
      format.json { render :json => @data }
    end
  end
end
