# frozen_string_literal: true

class CMS::HandlerInput < Formtastic::Inputs::SelectInput
  def options
    super.merge(collection: handlers, include_blank: '')
  end

  private

  def handlers
    CMS::Handler.available.map { |h| [h.to_s.humanize, h] }
  end
end
