class ResourcesController < ApplicationController
  def home
    render :template => 'resources/resources', :layout => 'application'
  end
end