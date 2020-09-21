# frozen_string_literal: true

class InvoiceDecorator < ApplicationDecorator
  # This smells of :reek:NilCheck
  def buyer
    @buyer ||= super&.decorate
  end
end
