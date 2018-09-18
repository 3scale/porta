class TrackController < ApplicationController
  def show
    render :json => {:domain => 'foo.bar.com'}, :callback => params[:callback]
  end
end