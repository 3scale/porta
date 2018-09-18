class ApiDocs::ProxyController < ApplicationController
  def show
    Rails.logger.info '[api_docs/proxy] not doing anything, you should run the api docs proxy'
    head(:not_found)
  end
end
