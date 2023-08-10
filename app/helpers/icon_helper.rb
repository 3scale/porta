# frozen_string_literal: true

module IconHelper

  def icon_link_to(name, icon_name, link, options = {})
    link_to "#{icon(icon_name)} #{h name}".html_safe, link, options
  end

  def icon(name, text = nil, fixed_width: false)
    image = "<i class='fa fa-#{h(name.to_s)} #{'fa-fw' if fixed_width}'></i>".html_safe

    if text
      image + ' ' + h(text)
    else
      image
    end
  end
end
