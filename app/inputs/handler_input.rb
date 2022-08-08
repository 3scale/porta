# frozen_string_literal: true

# CMS
class HandlerInput < Formtastic::Inputs::SelectInput
  def options
    super.merge(collection: handlers)
  end

  def include_blank
    true
  end

  private

  def handlers
    CMS::Handler.available.map { |h| [h.to_s.humanize, h] }
  end
end
