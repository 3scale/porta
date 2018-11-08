# frozen_string_literal: true

require 'action_controller/metal/http_authentication.rb'

ActionController::HttpAuthentication::Basic.module_eval do
  def auth_scheme(request)
    request.authorization.to_s.split(' ', 2).first
  end

  def auth_param(request)
    request.authorization.to_s.split(' ', 2).second
  end
end

