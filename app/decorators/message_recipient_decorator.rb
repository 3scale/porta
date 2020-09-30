# frozen_string_literal: true

class MessageRecipientDecorator < ApplicationDecorator
  def receiver
    @receiver ||= super&.decorate
  end

  def sender
    @sender ||= super&.decorate
  end
end
