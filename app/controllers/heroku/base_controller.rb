class Heroku::BaseController < ApplicationController

  include SiteAccountSupport
  include Heroku::ControllerMethods

  skip_before_action :verify_authenticity_token

end
