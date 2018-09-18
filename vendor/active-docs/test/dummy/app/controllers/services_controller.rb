class ServicesController < ApplicationController

  def index
    render :json => load('services'), :callback => params[:callback]
  end

  def show
    render :json => load(params[:id]), :callback => params[:callback]
  end

  private

  def load(name)
    ActiveSupport::JSON.decode(File.read("#{Rails.root}/lib/specs/#{name}.json"))
  end

end