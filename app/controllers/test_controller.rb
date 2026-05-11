# app/controllers/test_controller.rb
class TestController < ApplicationController
  def index
    User.where("name = '#{params[:name]}'")
  end
end
