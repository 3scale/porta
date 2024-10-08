# frozen_string_literal: true

class ProxyConfigDecorator < ApplicationDecorator
  delegate :display_name, to: :user, prefix: true

  def user
    @user ||= (super || User.new).decorate
  end
end
