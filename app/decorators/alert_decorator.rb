# frozen_string_literal: true

class AlertDecorator < ApplicationDecorator
  def icon
    variant = case utilization_range
              when 50 then :info
              when 80, 90 then :warning
              else :danger
              end
    h.pf_alert_icon variant, colored: true
  end

  def link_to_app
    if cinstance
      h.link_to(cinstance.name, h.provider_admin_application_path(cinstance))
    else
      h.tag.span '(deleted app)'
    end
  end

  def utilization_range
    @utilization_range ||= h.utilization_range(level)
  end
end
