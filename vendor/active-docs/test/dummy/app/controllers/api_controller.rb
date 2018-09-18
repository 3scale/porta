class ApiController < ApplicationController
  respond_to :json

  def index
    render :json => params
  end
end