# frozen_string_literal: true

class PasswordPresenter
  include ::Draper::ViewHelpers

  def initialize(user)
    @user = user
  end

  def change_password_props_json
    {
      lostPasswordToken: @user.lost_password_token,
      url: h.provider_password_path,
      errors: (@user.errors  || []).map { |key, value| {type: 'error', message: "#{key} #{value}"}}
    }.to_json
  end
end
