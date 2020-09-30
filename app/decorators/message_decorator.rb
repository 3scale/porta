# frozen_string_literal: true

class MessageDecorator < ApplicationDecorator
  def sender
    @sender ||= super&.decorate
  end

  def recipients
    @recipients ||= super&.decorate
  end
end
