# frozen_string_literal: true

class Admin::Api::Personal::BaseController < Admin::Api::BaseController
  before_action :login_required
  clear_respond_to
  respond_to :json

  def logged_in?
    current_user.present?
  end
end
